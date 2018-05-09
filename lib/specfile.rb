require 'rspec'
set :backend, :exec

dir = File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__)
require "#{dir}/probe"
require 'deep_merge'
require 'yaml'

deps = {}
deps_dir = ENV['SVCDEPS_PATH']
deps_files = []

raise "Environment variable 'SVCDEPS_PATH' must be set" unless deps_dir

Dir.chdir(deps_dir)
Dir.glob(File.join('**','*.yaml')).each {|f| deps_files << "#{deps_dir}/#{f}" } 
Dir.glob(File.join('**','*.yml')).each {|f| deps_files << "#{deps_dir}/#{f}" } 


def symbolize_keys(hash)
   hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v ; memo }
end

deps_files.each do |f|
  deps.deep_merge(YAML.load( File.read( f ) ) ) 
end

describe 'Service Dependencies' do 
  deps['deps'].each do |dep|
    dep = symbolize_keys(dep)
    it "#{dep[:desc]}" do 
      p = Probe.new( dep ) 
      expect { p.run }.to_not raise_error
    end
  end if deps['deps']
end
