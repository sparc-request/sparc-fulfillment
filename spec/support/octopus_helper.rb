class BlankModel < ActiveRecord::Base; end

module OctopusHelper
  def self.clean_all_shards
    ActiveRecord::Base.descendants.select { |model| model.respond_to?(:sparc_record?) }.each do |klass|
      klass.connection.execute("DELETE FROM #{klass.table_name}")
    end
  end
end
