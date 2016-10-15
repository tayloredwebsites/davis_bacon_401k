require 'test_helper'

class EmployeePackageTest < ActiveSupport::TestCase
  include NumberHandling

	fixtures :employees, :employee_packages, :employee_benefits, :name_values

  def test_allowed_packages_1
    pkgs_count = EmployeePackage.all.count
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 93
    saved_package = @emp_pkg.audit_save
    assert_equal saved_package, false
    assert !@emp_pkg.errors.empty?
    assert_equal ["can't be blank"], @emp_pkg.errors[:employee]

    @dup = EmployeePackage.find(:first, :conditions => "employee_id = 93")
    assert_nil @dup

    assert_equal EmployeePackage.all.count, pkgs_count
  end

  def test_allowed_employees_2
    pkgs_count = EmployeePackage.all.count
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3 # non-existant employee
    @emp_pkg.eff_year = 2000 # invalid effective year
    @emp_pkg.eff_month = 12
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
  	assert_not_equal @emp_pkg.errors[:eff_year], []
  	#assert_equal "can't be blank", @emp_pkg.errors[:last_name]

    assert_equal EmployeePackage.all.count, pkgs_count
  end

  def test_allowed_employees_3
    pkgs_count = EmployeePackage.all.count
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3 # non-existant employee
    @emp_pkg.eff_year = 2001
    @emp_pkg.eff_month = 13 # invalid effective month
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert_not_equal @emp_pkg.errors[:eff_month], []
  	#assert_equal "can't be blank", @emp_pkg.errors[:last_name]

    assert_equal EmployeePackage.all.count, pkgs_count
  end

  def test_allowed_employees_4
    pkgs_count = EmployeePackage.all.count
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3 # non-existant employee
    @emp_pkg.eff_year = 2000 # invalid effective year
    @emp_pkg.eff_month = 0 # invalid effective month
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert_not_equal @emp_pkg.errors[:eff_year], []
    assert_not_equal @emp_pkg.errors[:eff_month], []
  	#assert_equal "can't be blank", @emp_pkg.errors[:last_name]

    assert_equal EmployeePackage.all.count, pkgs_count
  end

  def test_allowed_employees_5
    pkgs_count = EmployeePackage.all.count
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3 # non-existant employee
    @emp_pkg.eff_year = 3000 # invalid effective year
    @emp_pkg.eff_month = 12
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert_not_equal @emp_pkg.errors[:eff_year], []
  	#assert_equal "can't be blank", @emp_pkg.errors[:last_name]

    assert_equal EmployeePackage.all.count, pkgs_count
  end

  def test_employee_referential_integrity
    pkgs_count = EmployeePackage.all.count
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3 # non-existant employee
    @emp_pkg.eff_year = 2001
    @emp_pkg.eff_month = 12
    saved_package = @emp_pkg.audit_save
    assert_equal saved_package, false
    assert !@emp_pkg.errors.empty?
  	assert_equal ["can't be blank"], @emp_pkg.errors[:employee]

    assert_equal EmployeePackage.all.count, pkgs_count
  end

  def test_collision

    @dup = EmployeePackage.find(:first, :conditions => "employee_id = 2")
    assert_not_nil @dup
    assert_equal @dup.employee_id, 2
    assert_equal @dup.hourly_wage, 27.6

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 12
    @emp_pkg.eff_year = 2006
    @emp_pkg.eff_month = 1
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    #assert @emp_pkg.errors[:employee_id')
  	#assert_equal "Error - invalid employee id.", @emp_pkg.errors[:employee_id]

    @recs = EmployeePackage.count(:conditions => "employee_id = 2")
    assert @dup = 1

  end

	def test_create
	    @emp_pkg = EmployeePackage.new

	    @emp_pkg.employee_id = 2
	    @emp_pkg.eff_year = 2001
	    @emp_pkg.eff_month = 12
	    assert @emp_pkg.audit_save
	    assert @emp_pkg.errors.empty?
	    assert_equal @emp_pkg.errors[:eff_year], []
	    assert_equal @emp_pkg.errors[:eff_month], []
	    assert_equal @emp_pkg.errors[:employee_id], []
	  	#assert_equal "Error - invalid employee id.", @emp_pkg.errors[:employee_id]
	  	#@emp_pkg.update
	  	@emp_pkg.reload
	  	assert_equal @emp_pkg.eff_month, 12
	  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 2")
	  	assert_equal @rec_count, 3
	end

  def test_destroy_1
    num_employee_packages = EmployeePackage.count
  	@emp_pkg = EmployeePackage.find(:first, :conditions => "employee_id = 1")
  	assert !@emp_pkg.destroy
  	assert @emp_pkg.errors.count > 0
  	assert_equal ['Error - cannot delete last package record.'], @emp_pkg.errors[:employee_id]
    assert_equal num_employee_packages, EmployeePackage.count
  	#@emp_pkg.update
  	#@emp_pkg.reload
  	#assert_equal @emp_pkg.deactivated, 1	# deactivated
  end

  def test_destroy_2
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 1
    @emp_pkg.eff_year = 2001
    @emp_pkg.eff_month = 12
    assert @emp_pkg.audit_save
    assert @emp_pkg.errors.empty?
    assert_equal @emp_pkg.errors[:eff_year], []
    assert_equal @emp_pkg.errors[:eff_month], []
    assert_equal @emp_pkg.errors[:employee_id], []
  	@emp_pkg.reload
  	assert_equal @emp_pkg.eff_month, 12
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 1")
  	assert_equal @rec_count, 2

    num_employee_packages = EmployeePackage.count
  	@emp_pkg = EmployeePackage.find(:first, :conditions => 'employee_id = 1', :order => 'eff_year DESC, eff_month DESC')
  	assert @emp_pkg.destroy
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 1")
  	assert_equal @rec_count, 1
  end

  def test_destroy_3
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 1
    @emp_pkg.eff_year = 2006
    @emp_pkg.eff_month = 12
    assert @emp_pkg.audit_save
    assert @emp_pkg.errors.empty?
    assert_equal @emp_pkg.errors[:eff_year], []
    assert_equal @emp_pkg.errors[:eff_month], []
    assert_equal @emp_pkg.errors[:employee_id], []
  	@emp_pkg.reload
  	assert_equal @emp_pkg.eff_month, 12
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 1")
  	assert_equal @rec_count, 2

    num_employee_packages = EmployeePackage.count(:conditions => "employee_id = 1")
  	assert_equal num_employee_packages, 2
  	@emp_pkg = EmployeePackage.find(1)
  	assert_equal @emp_pkg.deactivated, 0
  	assert @emp_pkg.destroy
  	assert_equal @emp_pkg.errors.count, 0
  	#assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors[:employee_id]
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 1")
  	assert_equal @rec_count, num_employee_packages - 1
    num_employee_packages = EmployeePackage.count(:conditions => "employee_id = 1")
  	assert_equal num_employee_packages, 1	# confirm actually destroyed, not deactivated
  end

  def test_destroy_4
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 2
    @emp_pkg.eff_year = 2006
    @emp_pkg.eff_month = 12
    assert @emp_pkg.audit_save
    assert @emp_pkg.errors.empty?
    assert_equal @emp_pkg.errors[:eff_year], []
    assert_equal @emp_pkg.errors[:eff_month], []
    assert_equal @emp_pkg.errors[:employee_id], []
  	@emp_pkg.reload
  	assert_equal @emp_pkg.eff_month, 12
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 2")
  	assert_equal @rec_count, 3

    num_employee_packages = EmployeePackage.count(:conditions => "employee_id = 2")
  	@emp_pkg = EmployeePackage.find(3)
  	assert_equal @emp_pkg.deactivated, 0
  	@dep_count = EmployeeBenefit.count(:conditions => "employee_package_id = 3 AND deposited_at IS NOT NULL ")
  	assert_equal @dep_count, 1
  	assert @emp_pkg.destroy
  	assert_equal @emp_pkg.errors.count, 0
  	#assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors[:employee_id]
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 2")
  	assert_equal @rec_count, num_employee_packages
  	@emp_pkg = EmployeePackage.find(:first, :conditions => 'employee_id = 2')
  	assert_equal @emp_pkg.deactivated, 1
  end

end
