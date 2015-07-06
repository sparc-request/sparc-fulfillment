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

          ldap.auth "uid=#{ldap_uid},#{ENV.fetch('LDAP_BASE')}", password

          if ldap.bind
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
