class SetDeactivatedDefaultFalse < ActiveRecord::Migration
  def self.up
    change_column_default :employee_packages, :deactivated, 0
    change_column_default :employees, :deactivated, 0
    change_column_default :users, :deactivated, 0
  end

  def self.down
    change_column_default :employee_packages, :deactivated, nil
    change_column_default :employees, :deactivated, nil
    change_column_default :users, :deactivated, nil
  end
end
