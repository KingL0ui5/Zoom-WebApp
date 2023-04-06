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

ActiveRecord::Schema.define(version: 20230406165003) do

  create_table "departments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meetingrecords", primary_key: "meeting_id", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "zoom_meeting_id",                               null: false
    t.datetime "start_time",                                    null: false
    t.integer  "duration",                                      null: false
    t.string   "meeting_type",                                  null: false
    t.integer  "department_id"
    t.integer  "EmployeeID"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "topic",           limit: 65535
    t.boolean  "started",                       default: false
    t.index ["EmployeeID"], name: "index_meetingrecords_on_EmployeeID", using: :btree
    t.index ["department_id"], name: "index_meetingrecords_on_department_id", using: :btree
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "session_id",               null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "users", primary_key: "EmployeeID", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "Name"
    t.string   "EmailAddress"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "department_id"
    t.string   "password_digest"
    t.index ["EmployeeID"], name: "index_users_on_EmployeeID", unique: true, using: :btree
    t.index ["department_id"], name: "index_users_on_department_id", using: :btree
  end

  add_foreign_key "meetingrecords", "departments"
  add_foreign_key "meetingrecords", "users", column: "EmployeeID", primary_key: "EmployeeID"
  add_foreign_key "users", "departments"
end
