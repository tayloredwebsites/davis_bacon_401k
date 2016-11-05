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

    @dup = EmployeePackage.where("employee_id = 93")
    assert_equal 0, @dup.count

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

    @dups = EmployeePackage.where("employee_id = 2")
    assert_not_equal 0, @dups.count
    @dup = @dups.first
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

    @recs = EmployeePackage.where("employee_id = 2").count
    assert @dup = 1

  end

	def test_create
      @rec_count = EmployeePackage.count("employee_id = 2")
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
	  	assert_equal @rec_count+1, EmployeePackage.count("employee_id = 2")
	end

  def test_destroy_1
    num_employee_packages = EmployeePackage.count
  	@emp_pkgs = EmployeePackage.where("employee_id = 1")
    assert_not_equal 0, @emp_pkgs.count
    @emp_pkg = @emp_pkgs.first
  	assert !@emp_pkg.destroy
  	assert @emp_pkg.errors.count > 0
  	assert_equal ['Error - cannot delete last package record.'], @emp_pkg.errors[:employee_id]
    assert_equal num_employee_packages, EmployeePackage.count
  	#@emp_pkg.update
  	#@emp_pkg.reload
  	#assert_equal @emp_pkg.deactivated, 1	# deactivated
  end

  def test_destroy_2
    @rec_count = EmployeePackage.count("employee_id = 1")
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
  	assert_equal @rec_count+1, EmployeePackage.count("employee_id = 1")

    num_employee_packages = EmployeePackage.count
  	@emp_pkg = EmployeePackage.where('employee_id = 1').order('eff_year DESC, eff_month DESC')
    assert_not_equal 0, @emp_pkg.count
  	assert @emp_pkg.first.destroy
  	assert_equal @rec_count, EmployeePackage.count("employee_id = 1")
  end

  def test_destroy_3
    @rec_count = EmployeePackage.count("employee_id = 1")
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
    assert_equal @rec_count+1, EmployeePackage.count("employee_id = 1")

  	@emp_pkg = EmployeePackage.find(1)
  	assert_not_equal 1, @emp_pkg.deactivated
  	assert @emp_pkg.destroy
  	assert_equal @emp_pkg.errors.count, 0
  	#assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors[:employee_id]
  	assert_equal @rec_count, EmployeePackage.count("employee_id = 1")
  end

  def test_destroy_4
    @rec_count = EmployeePackage.count("employee_id = 2")
    @dep_count = EmployeeBenefit.count("employee_package_id = 3 AND deposited_at IS NOT NULL ")
    @emp_pkg = EmployeePackage.new

    @emp_pkg.employee_id = 2
    @emp_pkg.eff_year = 2006
    @emp_pkg.eff_month = 12
    assert @emp_pkg.audit_save
    assert @emp_pkg.errors.empty?
    assert_equal @emp_pkg.errors[:eff_year], []
    assert_equal @emp_pkg.errors[:eff_month], []
    assert_equal @emp_pkg.errors[:employee_id], []
    Rails.logger.debug("++++ audit_saved @emp_pkg: #{@emp_pkg.inspect}")
  	@emp_pkg.reload
  	assert_equal @emp_pkg.eff_month, 12
    assert_equal @rec_count+1, EmployeePackage.count("employee_id = 2")
    Rails.logger.debug("+++ reloaded @emp_pkg: #{@emp_pkg.inspect}")

  	# @emp_pkg = EmployeePackage.find(3)
  	assert_not_equal 1, @emp_pkg.deactivated
    assert_equal 2, @emp_pkg.employee_id
  	assert @emp_pkg.destroy
  	assert_equal @emp_pkg.errors.count, 0
  	#assert_equal 'Error - cannot delete last package record.', @emp_pkg.errors[:employee_id]
  	assert_equal @rec_count, EmployeePackage.count("employee_id = 2")
  	@emp_pkgs = EmployeePackage.where('employee_id = 2')
    assert_not_equal 0, @emp_pkgs.count
    @emp_pkg = @emp_pkgs.first
    assert_equal 1, @emp_pkg.deactivated
    assert_equal @dep_count, EmployeeBenefit.count("employee_package_id = 3 AND deposited_at IS NOT NULL ")
  end

end
