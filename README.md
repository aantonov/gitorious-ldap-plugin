Gitorious Ldap Plugin
=============
TPlugin actually serves Griddynamics ldap synchronization,
and definetely should not be used for others.

Plugin uses **ldap.vm.griddynamics.net** as an ldap server. Make sure that this name is resolved properly.

#### Installation
	bundle exec ./script/plugin install git://github.com/gapcoder/gitorious-ldap-plugin.git -f 
	# Keep -f you want to force update your plugin

#### Available tasks

 	# Creating stub user for testing with  
 	# rake2@griddynamics.com/rake2 	 
 	rake ldap:create_user 
 	
 	# Printouts acceptable groups
 	rake ldap:get_groups
 	
 	# Reseting authorized keys at ~/.ssh/authorized_keys
 	rake ldap:reset_akeys
 	
 	# Synchronizes groups and users
 	rake ldap:sync_users
 	
 	# Synchronize users from the LDAP with the database
 	rake ldap:sync_groups 
 	

For common task do :
	 
	bundle exec rake -T | grep ldap 

Example
=======
In your gitorious root :

bundle exec rake ldap:sync_users


Copyright (c) 2012, released under the MIT license
