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

ActiveRecord::Schema.define(version: 20141112194351) do

  create_table "arms", force: true do |t|
    t.integer  "sparc_id"
    t.integer  "protocol_id"
    t.string   "name"
    t.integer  "visit_count"
    t.integer  "subject_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "line_items", force: true do |t|
    t.integer  "sparc_id"
    t.integer  "arm_id"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "sparc_core_id"
    t.string   "sparc_core_name"
    t.integer  "sparc_program_id"
    t.string   "sparc_program_name"
    t.string   "name"
    t.integer  "cost"
  end

  add_index "line_items", ["arm_id"], name: "index_line_items_on_arm_id", using: :btree
  add_index "line_items", ["service_id"], name: "index_line_items_on_service_id", using: :btree

  create_table "protocols", force: true do |t|
    t.integer  "sparc_id"
    t.text     "title"
    t.string   "short_title"
    t.string   "sponsor_name"
    t.string   "udac_project_number"
    t.integer  "requester_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "irb_status"
    t.datetime "irb_approval_date"
    t.datetime "irb_expiration_date"
    t.integer  "subsidy_amount"
    t.integer  "study_cost"
  end

  create_table "services", force: true do |t|
    t.integer  "sparc_id"
    t.decimal  "cost",         precision: 10, scale: 0
    t.string   "name"
    t.string   "abbreviation"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "visit_groups", force: true do |t|
    t.integer  "sparc_id"
    t.integer  "arm_id"
    t.integer  "position"
    t.string   "name"
    t.integer  "day"
    t.integer  "window_before"
    t.integer  "window_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "visit_groups", ["arm_id"], name: "index_visit_groups_on_arm_id", using: :btree

  create_table "visits", force: true do |t|
    t.integer  "sparc_id"
    t.integer  "line_item_id"
    t.integer  "visit_group_id"
    t.integer  "research_billing_qty"
    t.integer  "insurance_billing_qty"
    t.integer  "effort_billing_qty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "visits", ["line_item_id"], name: "index_visits_on_line_item_id", using: :btree
  add_index "visits", ["visit_group_id"], name: "index_visits_on_visit_group_id", using: :btree

end
