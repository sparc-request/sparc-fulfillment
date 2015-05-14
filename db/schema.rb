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

ActiveRecord::Schema.define(version: 20150514141207) do

  create_table "appointment_statuses", force: :cascade do |t|
    t.string   "status",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "appointment_id", limit: 4
  end

  create_table "appointments", force: :cascade do |t|
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
  add_index "arms", ["sparc_id"], name: "index_arms_on_sparc_id", unique: true, using: :btree

  create_table "components", force: :cascade do |t|
    t.string   "component",       limit: 255
    t.integer  "position",        limit: 4
    t.integer  "composable_id",   limit: 4
    t.string   "composable_type", limit: 255
    t.boolean  "selected",        limit: 1,   default: false
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
    t.string   "doc_file_name",     limit: 255
    t.string   "doc_content_type",  limit: 255
    t.integer  "doc_file_size",     limit: 4
    t.datetime "doc_updated_at"
  end

  add_index "documents", ["documentable_id", "documentable_type"], name: "index_documents_on_documentable_id_and_documentable_type", using: :btree

  create_table "fulfillments", force: :cascade do |t|
    t.integer  "line_item_id", limit: 4
    t.datetime "fulfilled_at"
    t.integer  "quantity",     limit: 4
    t.integer  "performed_by", limit: 4
    t.integer  "created_by",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "fulfillments", ["line_item_id"], name: "index_fulfillments_on_line_item_id", using: :btree

  create_table "identity_counters", force: :cascade do |t|
    t.integer  "identity_id", limit: 4
    t.integer  "tasks_count", limit: 4, default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "identity_counters", ["identity_id"], name: "index_identity_counters_on_identity_id", using: :btree

  create_table "identity_roles", force: :cascade do |t|
    t.integer  "identity_id", limit: 4
    t.integer  "protocol_id", limit: 4
    t.string   "rights",      limit: 255
    t.string   "role",        limit: 255
    t.string   "role_other",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "identity_roles", ["identity_id"], name: "index_identity_roles_on_identity_id", using: :btree
  add_index "identity_roles", ["protocol_id"], name: "index_identity_roles_on_protocol_id", using: :btree

  create_table "line_items", force: :cascade do |t|
    t.integer  "sparc_id",           limit: 4
    t.integer  "arm_id",             limit: 4
    t.integer  "service_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "subject_count",      limit: 4
    t.boolean  "one_time_fee",       limit: 1
    t.integer  "per_unit_cost",      limit: 4,   default: 0
    t.integer  "quantity_requested", limit: 4,   default: 0
    t.string   "quantity_type",      limit: 255
    t.datetime "started_at"
    t.integer  "protocol_id",        limit: 4
  end

  add_index "line_items", ["arm_id"], name: "index_line_items_on_arm_id", using: :btree
  add_index "line_items", ["deleted_at"], name: "index_line_items_on_deleted_at", using: :btree
  add_index "line_items", ["service_id"], name: "index_line_items_on_service_id", using: :btree
  add_index "line_items", ["sparc_id"], name: "index_line_items_on_sparc_id", unique: true, using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "identity_id",  limit: 4
    t.string   "comment",      limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notable_id",   limit: 4
    t.string   "notable_type", limit: 255
    t.string   "reason",       limit: 255
    t.string   "kind",         limit: 255, default: "note"
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

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "type",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "protocol_id",        limit: 4
    t.integer  "arm_id",             limit: 4
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.integer  "mrn",                limit: 4
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

  create_table "procedures", force: :cascade do |t|
    t.integer  "appointment_id",  limit: 4
    t.string   "service_name",    limit: 255
    t.integer  "service_cost",    limit: 4
    t.integer  "service_id",      limit: 4
    t.string   "status",          limit: 255
    t.datetime "start_date"
    t.datetime "completed_date"
    t.string   "billing_type",    limit: 255
    t.string   "reason",          limit: 255
    t.integer  "sparc_core_id",   limit: 4
    t.string   "sparc_core_name", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visit_id",        limit: 4
  end

  add_index "procedures", ["appointment_id"], name: "index_procedures_on_appointment_id", using: :btree
  add_index "procedures", ["completed_date"], name: "index_procedures_on_completed_date", using: :btree
  add_index "procedures", ["service_id"], name: "index_procedures_on_service_id", using: :btree
  add_index "procedures", ["visit_id"], name: "index_procedures_on_visit_id", using: :btree

  create_table "protocols", force: :cascade do |t|
    t.integer  "sparc_id",                     limit: 4
    t.text     "title",                        limit: 65535
    t.string   "short_title",                  limit: 255
    t.string   "sponsor_name",                 limit: 255
    t.string   "udak_project_number",          limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "irb_status",                   limit: 255
    t.datetime "irb_approval_date"
    t.datetime "irb_expiration_date"
    t.float    "stored_percent_subsidy",       limit: 24
    t.integer  "study_cost",                   limit: 4
    t.integer  "sparc_sub_service_request_id", limit: 4
    t.string   "status",                       limit: 255
  end

  add_index "protocols", ["deleted_at"], name: "index_protocols_on_deleted_at", using: :btree
  add_index "protocols", ["sparc_id"], name: "index_protocols_on_sparc_id", unique: true, using: :btree

  create_table "tasks", force: :cascade do |t|
    t.date     "due_at"
    t.boolean  "complete",        limit: 1,     default: false
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
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "visit_groups", force: :cascade do |t|
    t.integer  "sparc_id",      limit: 4
    t.integer  "arm_id",        limit: 4
    t.integer  "position",      limit: 4
    t.string   "name",          limit: 255
    t.integer  "day",           limit: 4
    t.integer  "window_before", limit: 4
    t.integer  "window_after",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "visit_groups", ["arm_id"], name: "index_visit_groups_on_arm_id", using: :btree
  add_index "visit_groups", ["deleted_at"], name: "index_visit_groups_on_deleted_at", using: :btree
  add_index "visit_groups", ["position"], name: "index_visit_groups_on_position", using: :btree
  add_index "visit_groups", ["sparc_id"], name: "index_visit_groups_on_sparc_id", unique: true, using: :btree

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
  add_index "visits", ["sparc_id"], name: "index_visits_on_sparc_id", unique: true, using: :btree
  add_index "visits", ["visit_group_id"], name: "index_visits_on_visit_group_id", using: :btree

end
