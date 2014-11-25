class Participant < ActiveRecord::Base
  acts_as_paranoid

  after_save :update_via_faye

  belongs_to :protocol
  
  def update_via_faye
    channel = "/participants/#{self.protocol.id}/list"
    message = {:channel => channel, :data => "woohoo", :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end
