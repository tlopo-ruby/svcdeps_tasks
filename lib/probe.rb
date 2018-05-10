require 'socket'
require 'timeout'
require 'etc'
require 'yaml'
require 'net/http'
require 'openssl'

class Probe
  def initialize(opts)
    @type = opts[:type].downcase
    @timeout = opts[:timeout] || 5
    @opts = opts
  end

  def tcp_probe
    host = @opts[:host]
    port = @opts[:port] 
    Timeout::timeout(@timeout) do 
      TCPSocket.new(host, port).close
    end 
  end

  def udp_probe
    host = @opts[:host]
    port = @opts[:port]
    Timeout::timeout(@timeout) do 
      u = UDPSocket.new
      u.connect(host,port)
      u.puts "check"
    end
  end

  def command_probe
    cmd =  @opts[:command]
    run_as = @opts[:run_as]
    if run_as.nil? 
      run_as = 'nobody' if Process.uid.zero?
    else
      warn "WARNNG: Option 'run_as' requires root, ignoring it." unless Process.uid.zero? 
      run_as = nil unless Process.uid.zero? 
    end 

    Timeout::timeout(@timeout) do 
      user = Etc.getpwnam(run_as)
      pid = Process.fork do
        STDOUT.reopen('/dev/null')
        STDERR.reopen('/dev/null')
        unless run_as.nil? 
          Process.egid = Process.gid = user.gid
          Process.euid = Process.uid = user.uid
        end
        exec cmd
      end
      status = Process.wait pid
      exit_status = $?.exitstatus 
      raise "Command [#{cmd}] exited with #{exit_status}" if exit_status > 0
    end
  end

  def http_probe
    url = @opts[:url]
    method = @opts[:method] || 'get'
    payload = @opts[:payload]  if @opts.key? :payload
    insecure = @opts[:insecure] || false
    headers = @opts[:headers] || {}

    Timeout::timeout(@timeout) do 
      uri = URI(url)
      is_https = uri.scheme == 'https'
      
      uri.path = '/' if uri.path.empty? 
      req = Object.const_get("Net::HTTP::#{method.capitalize}").new(uri.path)
      req.body = payload
       
      headers.each {|k,v| req[k] = v }
    
      opts = {}

      if is_https
        if @opts[:ca_file] 
          opts[:ca_file] = @opts[:ca_file]
        end
        
        if @opts[:cert_file] 
          opts[:cert] = OpenSSL::X509::Certificate.new( File.read @opts[:cert_file] )
        end
  
        if @opts[:key_file] 
          opts[:key] =  OpenSSL::PKey::RSA.new( File.read @opts[:key_file] )
        end
      end
 
      opts[:use_ssl] = is_https 
      opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if is_https && insecure 
   
      Net::HTTP.start( uri.host, uri.port, opts ) do |http|
        res = http.request(req)
        raise "Request to #{url} returned code #{res.code}" unless res.code == '200'
      end
    end
  end

  def run 
    case @type 
      when 'tcp'
        tcp_probe 
      when 'udp'
        udp_probe
      when 'command'
        command_probe
      when 'http'
        http_probe
      else 
        raise "Type '#{@type}' not supported"
    end
  end
end

