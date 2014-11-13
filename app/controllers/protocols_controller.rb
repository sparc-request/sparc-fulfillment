class ProtocolsController < ApplicationController
  def index
    @protocols = Protocol.all
  end
end
