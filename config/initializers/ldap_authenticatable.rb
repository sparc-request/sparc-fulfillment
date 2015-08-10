require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:identity]
          ldap = Net::LDAP.new(host:       ENV.fetch('LDAP_HOST'), 
                               port:       ENV.fetch('LDAP_PORT'),
                               base:       ENV.fetch('LDAP_BASE'),
                               encryption: ENV.fetch('LDAP_ENCRYPTION').to_sym
                              )
          authenticated = false
          service_username = ENV.fetch('LDAP_AUTH_USERNAME'){ nil }
          service_password = ENV.fetch('LDAP_AUTH_PASSWORD'){ nil }
          if service_username && service_password
            # support LDAP service account usage
            ldap.auth service_username, service_password
            ldap.bind
            authenticated = ldap.authenticate(ldap_uid, password)  
          else
            # bind user directly to LDAP (without a service account)
            ldap.auth "uid=#{ldap_uid},#{ENV.fetch('LDAP_BASE')}", password
            authenticated = ldap.bind
          end
          
          if authenticated
            identity = Identity.find_by(ldap_uid: [ldap_uid, ENV.fetch('LDAP_USER_DOMAIN')].join)
            success!(identity)
          else
            fail(:invalid_login)
          end
        end
      end

      def ldap_uid
        params[:identity][:ldap_uid]
      end

      def password
        params[:identity][:password]
      end

    end
  end
end

if ENV.fetch('INCLUDE_LDAP_AUTHENTICATION') == 'true'
  Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
end
