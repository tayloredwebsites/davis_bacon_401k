class InitialMigration < ActiveRecord::Migration
  def self.up


  create_table "employee_benefits", :force => true do |t|
    t.integer  "employee_id",                                                         :null => false
    t.integer  "employee_package_id"
    t.integer  "eff_month",                                         :default => 1
    t.integer  "eff_year",                                          :default => 2001
    t.decimal  "reg_hours",           :precision => 8, :scale => 2
    t.decimal  "ot_hours",            :precision => 8, :scale => 2
    t.decimal  "hourly_benefit",      :precision => 8, :scale => 2
    t.decimal  "monthly_benefit",     :precision => 8, :scale => 2
    t.decimal  "deposit",             :precision => 8, :scale => 2
    t.integer  "dep_eff_month"
    t.integer  "dep_eff_year"
    t.datetime "deposited_at"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "lock_version",                                      :default => 0
  end

  create_table "employee_packages", :force => true do |t|
    t.integer  "employee_id",                                                                  :null => false
    t.decimal  "hourly_wage",                  :precision => 8, :scale => 2
    t.decimal  "monthly_medical",              :precision => 8, :scale => 2
    t.decimal  "annual_sick",                  :precision => 8, :scale => 2
    t.decimal  "annual_holiday",               :precision => 8, :scale => 2
    t.decimal  "annual_vacation",              :precision => 8, :scale => 2
    t.decimal  "annual_personal",              :precision => 8, :scale => 2
    t.integer  "eff_month",                                                  :default => 1
    t.integer  "eff_year",                                                   :default => 2001
    t.integer  "deactivated",     :limit => 2
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.integer  "lock_version",                                               :default => 0
  end

  create_table "employees", :force => true do |t|
    t.integer  "emp_id",                                     :null => false
    t.integer  "user_id"
    t.string   "last_name",    :limit => 40
    t.string   "first_name",   :limit => 40
    t.string   "mi",           :limit => 1
    t.string   "ssn",          :limit => 9,  :default => "", :null => false
    t.integer  "deactivated",  :limit => 2
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "lock_version",               :default => 0
  end

  add_index "employees", ["emp_id"], :name => "employees_ix_employees_emp_id", :unique => true
  add_index "employees", ["ssn"], :name => "employees_ix_employees_emp_ssn", :unique => true

  create_table "name_values", :force => true do |t|
    t.string  "val_name",     :limit => 40
    t.string  "val_value"
    t.integer "lock_version",               :default => 0
  end

  add_index "name_values", ["val_name"], :name => "name_values_ix_name_values_val_value", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",        :limit => 80
    t.string   "password",     :limit => 40
    t.integer  "supervisor",   :limit => 2
    t.integer  "deactivated",  :limit => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "lock_version",               :default => 0
  end

  add_index "users", ["login"], :name => "users_ix_users_login", :unique => true


  end

  def self.down
  end
end
