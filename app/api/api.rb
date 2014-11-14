require 'v1/base'

module API 

	class Base < Grape::API

	  mount CWFSPARC::V1::APIv1
  end
end