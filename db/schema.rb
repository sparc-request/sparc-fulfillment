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

# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170405140625) do

  create_table "appointment_statuses", force: :cascade do |t|
    t.string   "status",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "appointment_id", limit: 4
  end

  create_table "appointments", force: :cascade do |t|
    t.integer  "sparc_id",             limit: 4
    t.integer  "participant_id",       limit: 4
    t.integer  "visit_group_id",       limit: 4
    t.integer  "visit_group_position", limit: 4
    t.integer  "position",             limit: 4
    t.string   "name",                 limit: 255
    t.datetime "start_date"
    t.datetime "completed_date"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contents",             limit: 255
    t.string   "type",                 limit: 255, default: "Appointment"
    t.integer  "arm_id",               limit: 4
  end

  add_index "appointments", ["arm_id"], name: "index_appointments_on_arm_id", using: :btree
  add_index "appointments", ["sparc_id"], name: "index_appointments_on_sparc_id", using: :btree
  add_index "appointments", ["type"], name: "index_appointments_on_type", using: :btree

  create_table "arms", force: :cascade do |t|
    t.integer  "sparc_id",      limit: 4
    t.integer  "protocol_id",   limit: 4
    t.string   "name",          limit: 255
    t.integer  "visit_count",   limit: 4
    t.integer  "subject_count", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "arms", ["deleted_at"], name: "index_arms_on_deleted_at", using: :btree
  add_index "arms", ["protocol_id"], name: "index_arms_on_protocol_id", using: :btree
  add_index "arms", ["sparc_id"], name: "index_arms_on_sparc_id", using: :btree

  create_table "components", force: :cascade do |t|
    t.string   "component",       limit: 255
    t.integer  "position",        limit: 4
    t.integer  "composable_id",   limit: 4
    t.string   "composable_type", limit: 255
    t.boolean  "selected",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "components", ["composable_id", "composable_type"], name: "index_components_on_composable_id_and_composable_type", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "documentable_id",   limit: 4
    t.string   "documentable_type", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",             limit: 255
    t.string   "state",             limit: 255,   default: "Processing"
    t.datetime "last_accessed_at"
    t.string   "original_filename", limit: 255
    t.string   "content_type",      limit: 255
    t.string   "report_type",       limit: 255
    t.text     "stack_trace",       limit: 65535
  end

  add_index "documents", ["documentable_id", "documentable_type"], name: "index_documents_on_documentable_id_and_documentable_type", using: :btree

  create_table "fulfillments", force: :cascade do |t|
    t.integer  "sparc_id",      limit: 4
    t.integer  "line_item_id",  limit: 4
    t.datetime "fulfilled_at"
    t.decimal  "quantity",                  precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "creator_id",    limit: 4
    t.integer  "performer_id",  limit: 4
    t.integer  "service_id",    limit: 4
    t.string   "service_name",  limit: 255
    t.integer  "service_cost",  limit: 4
    t.integer  "klok_entry_id", limit: 4
  end

  add_index "fulfillments", ["creator_id"], name: "index_fulfillments_on_creator_id", using: :btree
  add_index "fulfillments", ["klok_entry_id"], name: "index_fulfillments_on_klok_entry_id", using: :btree
  add_index "fulfillments", ["line_item_id"], name: "index_fulfillments_on_line_item_id", using: :btree
  add_index "fulfillments", ["performer_id"], name: "index_fulfillments_on_performer_id", using: :btree
  add_index "fulfillments", ["service_id"], name: "index_fulfillments_on_service_id", using: :btree
  add_index "fulfillments", ["sparc_id"], name: "index_fulfillments_on_sparc_id", using: :btree

  create_table "identity_counters", force: :cascade do |t|
    t.integer  "identity_id",                limit: 4
    t.integer  "tasks_count",                limit: 4, default: 0
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "unaccessed_documents_count", limit: 4, default: 0
  end

  add_index "identity_counters", ["identity_id"], name: "index_identity_counters_on_identity_id", using: :btree

  create_table "imports", force: :cascade do |t|
    t.string   "file",                  limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "title",                 limit: 255
    t.string   "file_file_name",        limit: 255
    t.string   "file_content_type",     limit: 255
    t.integer  "file_file_size",        limit: 4
    t.datetime "file_updated_at"
    t.string   "xml_file_file_name",    limit: 255
    t.string   "xml_file_content_type", limit: 255
    t.integer  "xml_file_file_size",    limit: 4
    t.datetime "xml_file_updated_at"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "sparc_id",           limit: 4
    t.integer  "arm_id",             limit: 4
    t.integer  "service_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "subject_count",      limit: 4,                            default: 0
    t.decimal  "quantity_requested",             precision: 10, scale: 2, default: 0.0
    t.string   "quantity_type",      limit: 255
    t.datetime "started_at"
    t.integer  "protocol_id",        limit: 4
    t.string   "name",               limit: 255
    t.string   "account_number",     limit: 255
    t.string   "contact_name",       limit: 255
  end

  add_index "line_items", ["arm_id"], name: "index_line_items_on_arm_id", using: :btree
  add_index "line_items", ["deleted_at"], name: "index_line_items_on_deleted_at", using: :btree
  add_index "line_items", ["service_id"], name: "index_line_items_on_service_id", using: :btree
  add_index "line_items", ["sparc_id"], name: "index_line_items_on_sparc_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "identity_id",  limit: 4
    t.text     "comment",      limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notable_id",   limit: 4
    t.string   "notable_type", limit: 255
    t.string   "reason",       limit: 255
    t.string   "kind",         limit: 255,   default: "note"
  end

  add_index "notes", ["identity_id"], name: "index_notes_on_identity_id", using: :btree
  add_index "notes", ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "sparc_id",     limit: 4
    t.string   "action",       limit: 255
    t.string   "callback_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",         limit: 255
  end

  add_index "notifications", ["sparc_id"], name: "index_notifications_on_sparc_id", using: :btree

  create_table "participants", force: :cascade do |t|
    t.integer  "sparc_id",           limit: 4
    t.integer  "protocol_id",        limit: 4
    t.integer  "arm_id",             limit: 4
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.string   "mrn",                limit: 255
    t.string   "status",             limit: 255
    t.datetime "date_of_birth"
    t.string   "gender",             limit: 255
    t.string   "ethnicity",          limit: 255
    t.string   "race",               limit: 255
    t.string   "address",            limit: 255
    t.string   "phone",              limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_cost",         limit: 4
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.string   "zipcode",            limit: 255
    t.string   "recruitment_source", limit: 255
    t.string   "external_id",        limit: 255
    t.string   "middle_initial",     limit: 1
  end

  add_index "participants", ["arm_id"], name: "index_participants_on_arm_id", using: :btree
  add_index "participants", ["deleted_at"], name: "index_participants_on_deleted_at", using: :btree
  add_index "participants", ["protocol_id"], name: "index_participants_on_protocol_id", using: :btree
  add_index "participants", ["sparc_id"], name: "index_participants_on_sparc_id", using: :btree

  create_table "procedures", force: :cascade do |t|
    t.integer  "sparc_id",         limit: 4
    t.integer  "appointment_id",   limit: 4
    t.string   "service_name",     limit: 255
    t.integer  "service_cost",     limit: 4
    t.integer  "service_id",       limit: 4
    t.string   "status",           limit: 255, default: "unstarted"
    t.datetime "completed_date"
    t.string   "billing_type",     limit: 255
    t.integer  "sparc_core_id",    limit: 4
    t.string   "sparc_core_name",  limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visit_id",         limit: 4
    t.integer  "performer_id",     limit: 4
    t.datetime "incompleted_date"
  end

  add_index "procedures", ["appointment_id"], name: "index_procedures_on_appointment_id", using: :btree
  add_index "procedures", ["completed_date"], name: "index_procedures_on_completed_date", using: :btree
  add_index "procedures", ["service_id"], name: "index_procedures_on_service_id", using: :btree
  add_index "procedures", ["sparc_id"], name: "index_procedures_on_sparc_id", using: :btree
  add_index "procedures", ["visit_id"], name: "index_procedures_on_visit_id", using: :btree

  create_table "protocols", force: :cascade do |t|
    t.integer  "sparc_id",                   limit: 4
    t.string   "sponsor_name",               limit: 255
    t.string   "udak_project_number",        limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "study_cost",                 limit: 4
    t.integer  "sub_service_request_id",     limit: 4
    t.integer  "unaccessed_documents_count", limit: 4,   default: 0
  end

  add_index "protocols", ["deleted_at"], name: "index_protocols_on_deleted_at", using: :btree
  add_index "protocols", ["sparc_id"], name: "index_protocols_on_sparc_id", using: :btree
  add_index "protocols", ["sub_service_request_id"], name: "index_protocols_on_sub_service_request_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.date     "due_at"
    t.boolean  "complete",                      default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "identity_id",     limit: 4
    t.integer  "assignee_id",     limit: 4
    t.string   "assignable_type", limit: 255
    t.integer  "assignable_id",   limit: 4
    t.text     "body",            limit: 65535
  end

  add_index "tasks", ["assignable_id", "assignable_type"], name: "index_tasks_on_assignable_id_and_assignable_type", using: :btree
  add_index "tasks", ["assignee_id"], name: "index_tasks_on_assignee_id", using: :btree
  add_index "tasks", ["identity_id"], name: "index_tasks_on_identity_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,   null: false
    t.integer  "item_id",        limit: 4,     null: false
    t.string   "event",          limit: 255,   null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "visit_groups", force: :cascade do |t|
    t.integer  "sparc_id",      limit: 4
    t.integer  "arm_id",        limit: 4
    t.integer  "position",      limit: 4
    t.string   "name",          limit: 255
    t.integer  "day",           limit: 4
    t.integer  "window_before", limit: 4,   default: 0
    t.integer  "window_after",  limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "visit_groups", ["arm_id"], name: "index_visit_groups_on_arm_id", using: :btree
  add_index "visit_groups", ["deleted_at"], name: "index_visit_groups_on_deleted_at", using: :btree
  add_index "visit_groups", ["position"], name: "index_visit_groups_on_position", using: :btree
  add_index "visit_groups", ["sparc_id"], name: "index_visit_groups_on_sparc_id", using: :btree

  create_table "visits", force: :cascade do |t|
    t.integer  "sparc_id",              limit: 4
    t.integer  "line_item_id",          limit: 4
    t.integer  "visit_group_id",        limit: 4
    t.integer  "research_billing_qty",  limit: 4
    t.integer  "insurance_billing_qty", limit: 4
    t.integer  "effort_billing_qty",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "visits", ["deleted_at"], name: "index_visits_on_deleted_at", using: :btree
  add_index "visits", ["line_item_id"], name: "index_visits_on_line_item_id", using: :btree
  add_index "visits", ["sparc_id"], name: "index_visits_on_sparc_id", using: :btree
  add_index "visits", ["visit_group_id"], name: "index_visits_on_visit_group_id", using: :btree

end
