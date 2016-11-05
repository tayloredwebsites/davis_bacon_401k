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

ActiveRecord::Schema.define(version: 20161030200250) do

  create_table "employee_benefits", force: :cascade do |t|
    t.integer  "employee_id",                                                null: false
    t.integer  "employee_package_id"
    t.integer  "eff_month",                                   default: 1
    t.integer  "eff_year",                                    default: 2001
    t.decimal  "reg_hours",           precision: 8, scale: 2
    t.decimal  "ot_hours",            precision: 8, scale: 2
    t.decimal  "hourly_benefit",      precision: 8, scale: 2
    t.decimal  "monthly_benefit",     precision: 8, scale: 2
    t.decimal  "deposit",             precision: 8, scale: 2
    t.integer  "dep_eff_month"
    t.integer  "dep_eff_year"
    t.datetime "deposited_at"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "lock_version",                                default: 0
  end

  create_table "employee_packages", force: :cascade do |t|
    t.integer  "employee_id",                              null: false
    t.decimal  "hourly_wage"
    t.decimal  "monthly_medical"
    t.decimal  "annual_sick"
    t.decimal  "annual_holiday"
    t.decimal  "annual_vacation"
    t.decimal  "annual_personal"
    t.integer  "eff_month",                 default: 1
    t.integer  "eff_year",                  default: 2001
    t.integer  "deactivated",     limit: 2, default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "lock_version",              default: 0
    t.float    "safe_harbor_pct", limit: 5, default: 0.0
  end

  create_table "employees", force: :cascade do |t|
    t.integer  "emp_id",                               null: false
    t.integer  "user_id"
    t.string   "last_name",    limit: 40
    t.string   "first_name",   limit: 40
    t.string   "mi",           limit: 1
    t.string   "ssn",          limit: 9,  default: "", null: false
    t.integer  "deactivated",  limit: 2,  default: 0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "lock_version",            default: 0
  end

  add_index "employees", ["emp_id"], name: "employees_ix_employees_emp_id", unique: true
  add_index "employees", ["ssn"], name: "employees_ix_employees_emp_ssn", unique: true

  create_table "name_values", force: :cascade do |t|
    t.string  "val_name",     limit: 40
    t.string  "val_value"
    t.integer "lock_version",            default: 0
  end

  add_index "name_values", ["val_name"], name: "name_values_ix_name_values_val_value", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "login",        limit: 80
    t.string   "password",     limit: 40
    t.integer  "supervisor",   limit: 2
    t.integer  "deactivated",  limit: 2,  default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "lock_version",            default: 0
  end

  add_index "users", ["login"], name: "users_ix_users_login", unique: true

end
