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
   
    RSpec::Core::Runner.run(["#{dir}/specfile.rb"])
    raise "RSpec exit status #{$?.exitstatus}" unless $?.success?
  end
end
