require 'common'

# Gitorious rails environment should be available

module GitoriousLdap

  class GitoriousLdap < Exception;
  end

  class ModelActions

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
      user_hash = {  # hash to pass to user constructor
          "login" => param[:login],
          "email" => param[:email],
          "terms_of_use" => "1",
          "password" => param[:login],
          "password_confirmation" =>param[:login]
      }
      user = User.new(user_hash)

      user.email = param[:email]
      user.login = param[:login]
      user.password = param[:login]
      user.password_confirmation = param[:login]
      user.fullname = param[:full_name] unless param[:full_name].nil?
      user.save!
      user.accept_terms!
      user.activate

      puts "User '#{user.login}' created with id: #{user.id}"

      unless param[:ssh_public_key].nil?
        puts "Creating ssh-public key"
        @ssh_key = user.ssh_keys.new
        @ssh_key.key = param[:ssh_public_key]
        if @ssh_key.save
          puts "Ssh key added successfully"
        else
          puts "Unable to save ssh-key!"
        end
      end

      user

    end


  end

end
