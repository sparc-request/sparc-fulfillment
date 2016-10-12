# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
