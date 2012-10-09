# GitoriousLdap

if RUBY_VERSION < '1.9'
  require 'rubygems'
end

require 'ldap'

#
# Install ruby-ldap gem first
# sudo gem install ruby-ldap
#


#
# Returns array of ldap groups for ldap user entry
#
def get_user_groups(ldap_entry)
  groups = []
  ldap_entry.dn.split(',').each { |dn|
    tmp = dn.split('=')
    if tmp[0] == 'ou'
      groups << tmp[1]
    end
  }
  groups
end


#
# Returns true if ldap entry has groups people, griddynamics and hasn't group deleted, otherwise false
#
def is_employee(ldap_entry)
  groups = get_user_groups(ldap_entry)

  if groups.include?('people') and groups.include?('griddynamics') and not groups.include?('deleted')
    return true
  end

  false
end


#
# Gets information about LDAP users
#
# host: your LDAP hostname or IP address
# base: domain name, like 'dc=<subdomain>,dc=<domain>'
# scope: scope to search (base, one, sub). By default, LDAP::LDAP_SCOPE_SUBTREE
# filter: search filter equation
#
def get_users(host, base='dc=griddynamics,dc=net', scope=LDAP::LDAP_SCOPE_SUBTREE, filter='(objectclass=person)')

  puts "Getting users from #{host} with base #{base} with filter #{filter}"

  attrs = ['uid', 'mail', 'sn', 'givenName' ,'cn', 'sshPublicKey']

  conn = LDAP::Conn.new(host)

  puts "Connection received: #{conn.inspect}"

  conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)

  puts conn.bind('','')

  conn.perror("bind")

  begin
    users = Hash.new

    conn.search(base, scope, filter, attrs) { |entry|
      if is_employee(entry)
        users[entry.vals('uid')[0].dup] = {
            :email => entry.vals('mail')[0].dup,
            :name => entry.vals('givenName')[0].dup,
            :last_name => entry.vals('sn')[0].dup,
            :full_name => entry.vals('cn')[0].dup,
            :ssh_public_key => entry.vals('sshPublicKey').nil? ? nil : entry.vals('sshPublicKey')[0].dup,
            :groups => get_user_groups(entry)
        }
      end
      }
    return users
  rescue LDAP::ResultError
    conn.perror("search")
    exit
  end
  conn.perror("search")
  conn.unbind
end


#
# Gets information about LDAP groups
#
# host: your LDAP hostname or IP address
# base: domain name, like 'dc=<subdomain>,dc=<domain>'
# scope: scope to search (base, one, sub). By default, LDAP::LDAP_SCOPE_SUBTREE
#
def get_groups(host, base='dc=griddynamics,dc=net', scope=LDAP::LDAP_SCOPE_SUBTREE)
  attrs = ['cn', 'memberUid']

  conn = LDAP::Conn.new(host)
  conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
  puts conn.bind('','')

  conn.perror("bind")

  begin
    groups = Hash.new
    conn.search(base, scope, '(objectClass=groupOfNames)', attrs) { |entry|
      groups[entry.vals(attrs[0])[0]] = entry.vals(attrs[1])
    }
    return groups
  rescue LDAP::ResultError
    conn.perror("search")
    exit
  end
  conn.perror("search")
  conn.unbind
end


#
# Gets information about SSH public key for specified user
#
# host: your LDAP hostname or IP address
# base: domain name, like 'dc=<subdomain>,dc=<domain>'
# scope: scope to search (base, one, sub). By default, LDAP::LDAP_SCOPE_SUBTREE
# username: ldap username (uid) for search
#
# Returns string value with ssh key, or nil if user isn't exists or not employee anymore
#
def get_ssh_public_key(host, base='dc=griddynamics,dc=net', scope=LDAP::LDAP_SCOPE_SUBTREE, username='iivanov')
  attrs = ['sshPublicKey']

  conn = LDAP::Conn.new(host)
  conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
  puts conn.bind('','')

  conn.perror("bind")

  begin
    sshPublicKey = nil
    conn.search(base, scope, "(uid=#{username})", attrs) { |entry|
      if is_employee(entry)
        sshPublicKey = entry.vals(attrs[0])
      end
    }
    return sshPublicKey
  rescue LDAP::ResultError
    conn.perror("search")
    exit
  end
  conn.perror("search")
  conn.unbind
end
