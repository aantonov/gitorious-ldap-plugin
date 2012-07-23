require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'


desc 'Integrate Gitorious users with the LDAP server'
task :ldap_users => :environment do
  puts "Hello ldap"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the gitorious_ldap plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the gitorious_ldap plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GitoriousLdap'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
