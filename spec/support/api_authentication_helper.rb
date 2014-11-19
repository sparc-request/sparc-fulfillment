module ApiAuthenticationHelper

  def http_login(username, password)
    @env ||= {}

    @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
