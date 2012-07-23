namespace :ldap do
  desc "Synchronize users from the LDAP with the database"
  task :sync_users => :environment do

    require 'awesome_print'

    gd_ldap_ip = '172.16.13.3'

    ldap_users = get_users(gd_ldap_ip)

    ldap_users.each_pair do |login, hhash|
      user_hash = {
          :login => login.dup,
          :password => login.dup
      }.merge!(hhash.dup)

      GitoriousLdap::ModelActions.create_user(user_hash, true)
    end

  end

  task :create_user => :environment do
    user_hash = {
          :email =>"rake2@griddynamics.com",
          :password =>"rake2",
          :login =>"rake2",
          :ssh_public_key => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZiAMQw8YtoybEESvxhLlU2lCMf0QIBowgO9Umh0fwmTkysvKtQYyge00uo7N3isq5w4vX40HJ1gPrrglsyDAoDXaEiwVB9ujMTxkGUgfCeF74Q1RdQ+i6D+jMdDYBusvMpkihRWf41B5dAQwDJiJ3t3h7PpUvz/cvHKiN0JQqS3V80ZD/uDUoZaaLFmKa8iP/Aoeu22D+1g3efxFqvk4K3SIKDvwc4n0wN2boCjyvj7EbGn5v69xCOIWyQiK2o87izlzG3MiUIgL6VQPdFRhcfWk58Uc3AlZomeZ55PJoCHySZPfa+UjRtmXyHQHDM8tYv+XfIByQQBj4THr0N9MZ foxie@foxie\n"
      }

    GitoriousLdap::ModelActions.create_user(user_hash, true)

  end

end

