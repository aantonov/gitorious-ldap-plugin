# Include hook code here
require 'logger'
LOG = Logger.new($stdout) unless defined? LOG

require 'gitorious_ldap'
require 'model_creation'
