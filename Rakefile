# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'synfeld_info'

task :default => 'spec:run'

PROJ.name = 'synfeld'
PROJ.authors = 'Steven Swerling'
PROJ.email = 'sswerling@yahoo.com'
PROJ.url = 'http://tab-a.slot-z.net'
PROJ.version = Synfeld::VERSION
PROJ.rubyforge.name = 'synfeld'
PROJ.gem.dependencies = ['rack', 'rack-router']
PROJ.rdoc.opts = ["--inline-source"]
PROJ.rdoc.exclude = ["^tasks/setup\.rb$", "lib/synfeld_info.rb"]

PROJ.spec.opts << '--color'

task :default => 'spec:run'
namespace :my do
  namespace :gem do
    task :package => [:clobber] do
      this_dir = File.join(File.dirname(__FILE__))
      sh "rm -rf #{File.join(this_dir, 'pkg')}"
      sh "rm -rf #{File.join(this_dir, 'doc')}"
      sh "cp #{File.join(this_dir, 'README.txt')} #{File.join(this_dir, 'README.rdoc')} "
      Rake::Task['gem:package'].invoke
    end
  end
end

