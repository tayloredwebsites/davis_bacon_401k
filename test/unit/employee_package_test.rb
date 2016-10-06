require File.dirname(__FILE__) + '/../test_helper'

class EmployeePackageTest < Test::Unit::TestCase
	fixtures :employees, :employee_packages, :employee_benefits, :name_values

  def test_allowed_packages_1

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 93
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert !@emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
  	assert_equal "Error - invalid employee id.", @emp_pkg.errors.on(:employee_id)

    @dup = EmployeePackage.find(:first, :conditions => "employee_id = 93")
    assert_nil @dup

  end

  def test_allowed_employees_2

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3
    @emp_pkg.eff_year = 2000
    @emp_pkg.eff_month = 12
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
  	assert_not_equal @emp_pkg.errors.on(:eff_year), nil
    assert @emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
  	#assert_equal "can't be blank", @emp_pkg.errors.on(:last_name)

  end

  def test_allowed_employees_3

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3
    @emp_pkg.eff_year = 2001
    @emp_pkg.eff_month = 13
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert !@emp_pkg.errors.invalid?('eff_year')
    assert @emp_pkg.errors.invalid?('eff_month')
  	#assert_equal "can't be blank", @emp_pkg.errors.on(:last_name)

  end

  def test_allowed_employees_4

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3
    @emp_pkg.eff_year = 2000
    @emp_pkg.eff_month = 0
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert @emp_pkg.errors.invalid?('eff_year')
    assert @emp_pkg.errors.invalid?('eff_month')
  	#assert_equal "can't be blank", @emp_pkg.errors.on(:last_name)

  end

  def test_allowed_employees_5

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3
    @emp_pkg.eff_year = 3000
    @emp_pkg.eff_month = 12
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert @emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
  	#assert_equal "can't be blank", @emp_pkg.errors.on(:last_name)

  end

  def test_allowed_foreign_key

    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 3
    @emp_pkg.eff_year = 2001
    @emp_pkg.eff_month = 12
    assert !@emp_pkg.audit_save
    assert !@emp_pkg.errors.empty?
    assert !@emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
    #assert @emp_pkg.errors.invalid?('employee_id')
  	assert_equal "Error - invalid employee id.", @emp_pkg.errors.on(:employee_id)

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
    #assert @emp_pkg.errors.invalid?('employee_id')
  	#assert_equal "Error - invalid employee id.", @emp_pkg.errors.on(:employee_id)

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
	    assert !@emp_pkg.errors.invalid?('eff_year')
	    assert !@emp_pkg.errors.invalid?('eff_month')
	    assert !@emp_pkg.errors.invalid?('employee_id')
	  	#assert_equal "Error - invalid employee id.", @emp_pkg.errors.on(:employee_id)
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
  	assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors.on(:employee_id)
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
    assert !@emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
    assert !@emp_pkg.errors.invalid?('employee_id')
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
    assert !@emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
    assert !@emp_pkg.errors.invalid?('employee_id')
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
  	#assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors.on(:employee_id)
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
    assert !@emp_pkg.errors.invalid?('eff_year')
    assert !@emp_pkg.errors.invalid?('eff_month')
    assert !@emp_pkg.errors.invalid?('employee_id')
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
  	#assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors.on(:employee_id)
  	@rec_count = EmployeePackage.count(:conditions => "employee_id = 2")
  	assert_equal @rec_count, num_employee_packages
  	@emp_pkg = EmployeePackage.find(:first, :conditions => 'employee_id = 2')
  	assert_equal @emp_pkg.deactivated, 1
  end

end
