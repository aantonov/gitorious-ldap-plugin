# GitoriousLdap

require 'rubygems'
require 'ldap'

#
# Install ruby-ldap gem first
# sudo gem install ruby-ldap
#

#
# Gets information about LDAP users
#
# host: your LDAP hostname or IP address
# base: domain name, like 'dc=<subdomain>,dc=<domain>'
# scope: scope to search (base, one, sub). By default, LDAP::LDAP_SCOPE_SUBTREE
# filter: search filter equation
#

def get_users(host, base='dc=griddynamics,dc=net', scope=LDAP::LDAP_SCOPE_SUBTREE, filter='(objectclass=person)')
  attrs = ['uid', 'mail', 'sn', 'givenName' ,'cn', 'sshPublicKey']

  conn = LDAP::Conn.new(host)
  conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
  puts conn.bind('','')

  conn.perror("bind")

  begin
    users = Hash.new

    conn.search(base, scope, filter, attrs) { |entry|
      groups = []
      entry.dn.split(',').each { |dn|
        tmp = dn.split('=')
        if tmp[0] == 'ou'
          groups << tmp[1]
        end
      }

      if groups.include?('people') and groups.include?('griddynamics') and not groups.include?('deleted')
        users[entry.vals('uid')[0].dup] = {
            :email => entry.vals('mail')[0].dup,
            :name => entry.vals('givenName')[0].dup,
            :last_name => entry.vals('sn')[0].dup,
            :full_name => entry.vals('cn')[0].dup,
            :ssh_public_key => entry.vals('sshPublicKey').nil? ? nil : entry.vals('sshPublicKey')[0].dup,
            :groups => groups.dup
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
      groups[entry.vals('cn')[0]] = entry.vals('memberUid')
    }
    return groups
  rescue LDAP::ResultError
    conn.perror("search")
    exit
  end
  conn.perror("search")
  conn.unbind
end