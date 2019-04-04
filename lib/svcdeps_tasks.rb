require 'svcdeps_tasks/version'
require 'rspec'
require 'rake'

dir = File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__)

namespace :spec do 
  desc 'run service dependencies specs '
  task :svcdeps do
    RSpec.configure do |c|
      c.add_formatter(:documentation)
     end
   
    exit_status = RSpec::Core::Runner.run(["#{dir}/specfile.rb"])
    raise "RSpec exit status #{exit_status}" unless exit_status.zero? 
  end
end
