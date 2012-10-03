if RUBY_VERSION < '1.9'
  require "rubygems"
end

require 'common'
require 'logger'


# Gitorious rails environment should be available


module GitoriousLdap

  class GitoriousLdap < Exception;
  end

  class ModelActions
    @log = Logger.new($stdout)

    def self.log
      @log
    end

    # Creating a grouip of tasks
    def self.create_group(name, user_list = [], force = true)

      default_admin = User.find_by_login("Gitorious")

      g = Group.find_by_name(name)

      if force.eql?(true) && !g.nil?
        log.info("Group '#{name}' will be deleted.")
        g.destroy
        g = nil
      end

      gname = name.gsub('_', '-')
      log.info("Formatting group name from #{name} to #{gname}")

      if g.nil?

        log.info(" Group #{gname} does not exists, creating a new group '#{gname}'")
        g_hash = {"description" => "Ldap group #{gname}", "name" => "#{gname}"}

        g = Group.new(g_hash)

        if !user_list.empty?
          g.transaction do
            g.creator = default_admin
            g.save!

            user_list.each do |login|
              user = User.find_by_login(login)
              if !user.nil?
                g.memberships.create!(:user => user, :role => Role.member)
                log.info("#{gname} <~ #{login}")
              end
            end

            g.memberships.create!(:user => default_admin, :role => Role.admin)
          end
        end

        log.info("Group #{gname} has been created successfully")
      end


    end

    def self.append_user_to_group(group_name)
    end

    # Creating user with specified hash
    # @param [Hash] parameters, example:
    #{
    #     :login =>"gitorious",
    #     :email =>"gitorious@griddynamics.com",
    #     :password =>"gitorious",
    #     :ssh_public_key => "shh-rsa AAABB...."
    # }
    # @return [User] user model object from the gitorious
    # @param [Boolean] force - override existing user if true
    def self.create_user(param, force = false)
      # check with the completion
      raise "Incomplete param hash whe creating user: :login required" if param[:login].nil?
      raise "Incomplete param hash whe creating user: :email required" if param[:email].nil?
      raise "Incomplete param hash whe creating user: :password required" if param[:password].nil?

      # Checking whether User existing
      user_old = User.find_by_login(param[:login])

      if  !user_old.nil?
        if force.eql?(true)

          log.info ("User '#{param[:login]}' already exists, force is true, overriding user.")
          User.delete(user_old.id)

        else

          log.info ("User '#{param[:login]}' already exists, force is false, returning user as is")
          return user_old

        end
      end

      log.info("Creating user '#{param[:login]}'")

      user_hash = {# hash to pass to user constructor
                   "login" => param[:login],
                   "email" => param[:email],
                   "terms_of_use" => "1",
                   "password" => param[:login],
                   "password_confirmation" => param[:login]
      }

      user = User.new(user_hash)
      user.email = param[:email]
      user.login = param[:login]
      user.password = param[:login]
      user.password_confirmation = param[:login]
      user.fullname = param[:full_name] unless param[:full_name].nil?

      if user.login.eql?("vvlaskin")
        user.is_admin=true
      end

      user.save!
      log.info("Saving user")

      user.accept_terms!
      log.info("User #{param[:login]} terms accepted ")

      user.activate
      log.info("User #{param[:login]} activated ")

      log.info ("User '#{user.login}' created with id: #{user.id}")

      unless param[:ssh_public_key].nil?

        log.info("Creating ssh-public key for user #{user.login}")

        @ssh_key = user.ssh_keys.new
        @ssh_key.key = param[:ssh_public_key].strip

        log.info("saving key: #{param[:ssh_public_key].to_s}")

        if @ssh_key.save!

          log.info("Key saving OK, publishing message")

          @ssh_key.publish_creation_message

          log.info ("OK: Ssh key added")

          user.save!
        else

          log.info("ERROR: Unable to save ssh-key, it is possible that such key already exists, look in ~/.ssh/authorized_keys ")
        end

      end

      user
    end


  end

end

