class Sparc::Report < ActiveRecord::Base
  require 'open-uri'

  include SparcShard

  belongs_to :sub_service_request

  def fetch
    url = ENV['GLOBAL_SCHEME'] + '://' + ENV['SPARC_API_HOST'] + '/system/reports/xlsxes/' + id_partition + '/original/' + xlsx_file_name + "?#{Time.now.to_f.to_i}"
    open(url).read 
  end

  # Returns the id of the instance in a split path form. e.g. returns
  # 000/001/234 for an id of 1234.
  def id_partition
    ("%09d" % id).scan(/\d{3}/).join("/")
  end
end
