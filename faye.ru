require 'faye'
require 'dotenv'
Dotenv.load

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if !message['ext'] || (message['ext']['auth_token'] != ENV.fetch('FAYE_TOKEN'))
        message['error'] = 'Invalid authentication token.'
      end
    end
    callback.call(message)
  end
end
# the FAYE_REFRESH_INTERVAL should be less than the faye.yml timeout value to prevent 502 errors in Firefox
faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => ENV.fetch('FAYE_REFRESH_INTERVAL', 45))
faye_server.add_extension(ServerAuth.new)

run faye_server
