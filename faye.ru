require 'faye'

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if !message['ext'] || (message['ext']['auth_token'] != ENV['FAYE_TOKEN'])
        message['error'] = 'Invalid authentication token.'
      end
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ServerAuth.new)
run faye_server
