# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

class AddPolymorphicColumnsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :assignable_type, :string
    add_column :tasks, :assignable_id, :integer
    add_column :tasks, :body, :text

    rename_column :tasks, :is_complete, :complete
    rename_column :tasks, :due_date, :due_at

    change_column :tasks, :complete, :boolean, default: false

    remove_column :tasks, :participant_name, :string
    remove_column :tasks, :protocol_id, :integer
    remove_column :tasks, :arm_name, :string
    remove_column :tasks, :task, :string
    remove_column :tasks, :task_type, :string
    remove_column :tasks, :visit_name, :string

    add_index "tasks", ["assignee_id"], name: "index_tasks_on_assignee_id", using: :btree
    add_index "tasks", ["assignable_id", "assignable_type"], name: "index_tasks_on_assignable_id_and_assignable_type", using: :btree
  end
end
