require 'common'

# Gitorious rails environment should be available

module GitoriousLdap

  class GitoriousLdap < Exception;
  end

  class ModelActions

    def self.create_group(name, user_list = [], force = true)
      g = Group.find_by_name(name)

      if force.eql?(true) && !g.nil?
        puts "Group '#{name}' will be forced!"
        g.destroy
        g = nil
      end

      if g.nil?
        puts " Group #{name} does not exists, creating a new group '#{name}'"
        g_hash = {"description" => "Ldap group #{name}", "name" => "#{name}"}
        g = Group.new(g_hash)
        if !user_list.empty?
          g.transaction do
            g.creator = User.find_by_login(user_list[0])
            g.save!

            user_list.each do |login|
              user = User.find_by_login(login)
              if !user.nil?
                g.memberships.create!({
                                          :user => user,
                                          :role => login.eql?(user_list.first) ? Role.admin : Role.member
                                      })
                puts "Group #{name} has included member #{login}"
              end
            end
          end
        end

        puts "Group #{name} has been created successfully"
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
    # }
    # @return [User] user model object from the gitorious
    # @param [Boolean] force - override existing user if true
    def self.create_user(param, force = false)
      # check
      raise "Incomplete param hash whe creating user: :login required" if param[:login].nil?
      raise "Incomplete param hash whe creating user: :email required" if param[:email].nil?
      raise "Incomplete param hash whe creating user: :password required" if param[:password].nil?

      # Checking whether User existing
      user_old = User.find_by_login(param[:login])

      if  !user_old.nil?
        if force.eql?(true)
          puts "User '#{param[:login]}' already exists, force is true, overriding user."
          User.delete(user_old.id)
        else
          puts "User '#{param[:login]}' already exists, force is false, returning user as is"
          return user_old
        end
      end

      puts "Creating user '#{param[:login]}'"
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

      if user.login == "vvlaskin"
        user.is_admin=true
      end

      user.save!
      user.accept_terms!
      user.activate

      puts "User '#{user.login}' created with id: #{user.id}"

      unless param[:ssh_public_key].nil?
        puts "Creating ssh-public key"
        @ssh_key = user.ssh_keys.new
        @ssh_key.key = param[:ssh_public_key]
        if @ssh_key.save
          @ssh_key.publish_creation_message if RAILS_ENV.eql?("production")
          puts "Ssh key added successfully"
        else
          puts "Unable to save ssh-key!"
        end
      end

      user

    end


  end

end

