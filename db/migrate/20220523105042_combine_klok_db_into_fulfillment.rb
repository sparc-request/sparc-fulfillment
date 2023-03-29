# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class CombineKlokDbIntoFulfillment < ActiveRecord::Migration[5.2]
  def change
    create_table :klok_entries, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.column :project_id, :integer, null: false
      t.column :resource_id, :integer
      t.column :rate, :integer
      t.column :date, :datetime
      t.column :start_time_stamp_formatted, :string, limit: 255
      t.column :start_time_stamp, :datetime
      t.primary_key :entry_id, :integer, null: false
      t.column :duration, :integer
      t.column :submission_id, :integer
      t.column :device_id, :integer
      t.column :comments, :text
      t.column :end_time_stamp_formatted, :string, limit: 255
      t.column :end_time_stamp, :datetime
      t.column :rollup_to, :integer
      t.column :enabled, :integer
      t.column :created_at, :datetime
    end

    create_table :klok_people, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.primary_key :resource_id, :integer, null: false
      t.column :name, :string, limit: 255
      t.column :username, :string, limit: 255
      t.column :created_at, :datetime
    end

    create_table :klok_projects, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.primary_key :project_id, :integer, null: false
      t.column :contact_email, :string, limit: 255
      t.column :path, :integer
      t.column :code, :string, limit: 255
      t.column :contact_phone, :string, limit: 255
      t.column :updated_at, :datetime
      t.column :project_type, :string, limit: 255
      t.column :name, :string, limit: 255
      t.column :parent_id, :integer
      t.column :created_at, :datetime
      t.column :contact_name, :string, limit: 255
      t.column :rollup_to, :integer
    end
  end
end
