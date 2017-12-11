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

ActiveRecord::Schema.define(version: 20171109153101) do

  create_table "appointment_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "appointment_id"
  end

  create_table "appointments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "participant_id"
    t.integer  "visit_group_id"
    t.integer  "visit_group_position"
    t.integer  "position"
    t.string   "name"
    t.datetime "start_date"
    t.datetime "completed_date"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contents"
    t.string   "type",                 default: "Appointment"
    t.integer  "arm_id"
    t.index ["arm_id"], name: "index_appointments_on_arm_id", using: :btree
    t.index ["sparc_id"], name: "index_appointments_on_sparc_id", using: :btree
    t.index ["type"], name: "index_appointments_on_type", using: :btree
  end

  create_table "arms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "protocol_id"
    t.string   "name"
    t.integer  "visit_count"
    t.integer  "subject_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_arms_on_deleted_at", using: :btree
    t.index ["protocol_id"], name: "index_arms_on_protocol_id", using: :btree
    t.index ["sparc_id"], name: "index_arms_on_sparc_id", using: :btree
  end

  create_table "components", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "component"
    t.integer  "position"
    t.integer  "composable_id"
    t.string   "composable_type"
    t.boolean  "selected",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["composable_id", "composable_type"], name: "index_components_on_composable_id_and_composable_type", using: :btree
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "priority",                 default: 0, null: false
    t.integer  "attempts",                 default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "state",                           default: "Processing"
    t.datetime "last_accessed_at"
    t.string   "original_filename"
    t.string   "content_type"
    t.string   "report_type"
    t.text     "stack_trace",       limit: 65535
    t.index ["documentable_id", "documentable_type"], name: "index_documents_on_documentable_id_and_documentable_type", using: :btree
  end

  create_table "fulfillments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "line_item_id"
    t.datetime "fulfilled_at"
    t.decimal  "quantity",      precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "creator_id"
    t.integer  "performer_id"
    t.integer  "service_id"
    t.string   "service_name"
    t.integer  "service_cost"
    t.integer  "klok_entry_id"
    t.index ["creator_id"], name: "index_fulfillments_on_creator_id", using: :btree
    t.index ["klok_entry_id"], name: "index_fulfillments_on_klok_entry_id", using: :btree
    t.index ["line_item_id"], name: "index_fulfillments_on_line_item_id", using: :btree
    t.index ["performer_id"], name: "index_fulfillments_on_performer_id", using: :btree
    t.index ["service_id"], name: "index_fulfillments_on_service_id", using: :btree
    t.index ["sparc_id"], name: "index_fulfillments_on_sparc_id", using: :btree
  end

  create_table "identity_counters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "identity_id"
    t.integer  "tasks_count",                default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "unaccessed_documents_count", default: 0
    t.index ["identity_id"], name: "index_identity_counters_on_identity_id", using: :btree
  end

  create_table "imports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "file"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "title"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "xml_file_file_name"
    t.string   "xml_file_content_type"
    t.integer  "xml_file_file_size"
    t.datetime "xml_file_updated_at"
  end

  create_table "line_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "arm_id"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "subject_count",                               default: 0
    t.decimal  "quantity_requested", precision: 10, scale: 2, default: "0.0"
    t.string   "quantity_type"
    t.datetime "started_at"
    t.integer  "protocol_id"
    t.string   "name"
    t.string   "account_number"
    t.string   "contact_name"
    t.index ["arm_id"], name: "index_line_items_on_arm_id", using: :btree
    t.index ["deleted_at"], name: "index_line_items_on_deleted_at", using: :btree
    t.index ["service_id"], name: "index_line_items_on_service_id", using: :btree
    t.index ["sparc_id"], name: "index_line_items_on_sparc_id", using: :btree
  end

  create_table "notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "identity_id"
    t.text     "comment",      limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.string   "reason"
    t.string   "kind",                       default: "note"
    t.index ["identity_id"], name: "index_notes_on_identity_id", using: :btree
    t.index ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type", using: :btree
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.string   "action"
    t.string   "callback_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
    t.index ["sparc_id"], name: "index_notifications_on_sparc_id", using: :btree
  end

  create_table "participants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "protocol_id"
    t.integer  "arm_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mrn"
    t.string   "status"
    t.datetime "date_of_birth"
    t.string   "gender"
    t.string   "ethnicity"
    t.string   "race"
    t.string   "address"
    t.string   "phone"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_cost"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "recruitment_source"
    t.string   "external_id"
    t.string   "middle_initial",     limit: 1
    t.index ["arm_id"], name: "index_participants_on_arm_id", using: :btree
    t.index ["deleted_at"], name: "index_participants_on_deleted_at", using: :btree
    t.index ["protocol_id"], name: "index_participants_on_protocol_id", using: :btree
    t.index ["sparc_id"], name: "index_participants_on_sparc_id", using: :btree
  end

  create_table "procedures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "appointment_id"
    t.string   "service_name"
    t.integer  "service_cost"
    t.integer  "service_id"
    t.string   "status",           default: "unstarted"
    t.datetime "completed_date"
    t.string   "billing_type"
    t.integer  "sparc_core_id"
    t.string   "sparc_core_name"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visit_id"
    t.integer  "performer_id"
    t.datetime "incompleted_date"
    t.index ["appointment_id"], name: "index_procedures_on_appointment_id", using: :btree
    t.index ["completed_date"], name: "index_procedures_on_completed_date", using: :btree
    t.index ["service_id"], name: "index_procedures_on_service_id", using: :btree
    t.index ["sparc_id"], name: "index_procedures_on_sparc_id", using: :btree
    t.index ["visit_id"], name: "index_procedures_on_visit_id", using: :btree
  end

  create_table "protocols", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.string   "sponsor_name"
    t.string   "udak_project_number"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "study_cost"
    t.integer  "sub_service_request_id"
    t.integer  "unaccessed_documents_count", default: 0
    t.index ["deleted_at"], name: "index_protocols_on_deleted_at", using: :btree
    t.index ["sparc_id"], name: "index_protocols_on_sparc_id", using: :btree
    t.index ["sub_service_request_id"], name: "index_protocols_on_sub_service_request_id", using: :btree
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "session_id",               null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.date     "due_at"
    t.boolean  "complete",                      default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "identity_id"
    t.integer  "assignee_id"
    t.string   "assignable_type"
    t.integer  "assignable_id"
    t.text     "body",            limit: 65535
    t.index ["assignable_id", "assignable_type"], name: "index_tasks_on_assignable_id_and_assignable_type", using: :btree
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id", using: :btree
    t.index ["identity_id"], name: "index_tasks_on_identity_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "email",                  default: "",                           null: false
    t.string   "encrypted_password",     default: "",                           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "time_zone",              default: "Eastern Time (US & Canada)"
    t.integer  "tasks_count",            default: 0
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "item_type",                    null: false
    t.integer  "item_id",                      null: false
    t.string   "event",                        null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "visit_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "arm_id"
    t.integer  "position"
    t.string   "name"
    t.integer  "day"
    t.integer  "window_before", default: 0
    t.integer  "window_after",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["arm_id"], name: "index_visit_groups_on_arm_id", using: :btree
    t.index ["deleted_at"], name: "index_visit_groups_on_deleted_at", using: :btree
    t.index ["position"], name: "index_visit_groups_on_position", using: :btree
    t.index ["sparc_id"], name: "index_visit_groups_on_sparc_id", using: :btree
  end

  create_table "visits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "sparc_id"
    t.integer  "line_item_id"
    t.integer  "visit_group_id"
    t.integer  "research_billing_qty"
    t.integer  "insurance_billing_qty"
    t.integer  "effort_billing_qty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_visits_on_deleted_at", using: :btree
    t.index ["line_item_id"], name: "index_visits_on_line_item_id", using: :btree
    t.index ["sparc_id"], name: "index_visits_on_sparc_id", using: :btree
    t.index ["visit_group_id"], name: "index_visits_on_visit_group_id", using: :btree
  end

end
