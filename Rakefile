require "bundler/gem_tasks"
require "rake/testtask"

task :default => [ :test ]

task :tasks do
  puts "Tasks:"
  puts "install : Build and install seiso-import_chef gem"
  puts "test    : Run unit tests"
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList[ 'test/**/test_*.rb' ]
  t.verbose = true
  t.warning = true
end
