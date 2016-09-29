class SafeHarbor < ActiveRecord::Migration
  def self.up
    add_column :employee_packages, :safe_harbor_pct, :float, :limit => 5, :default => 0.0
  end

  def self.down
    remove_column :employee_packages, :safe_harbor_pct
  end
end
