require File.dirname(__FILE__) + '/../test_helper'

class EmployeeBenefitTest < Test::Unit::TestCase
	fixtures :employees, :employee_packages, :employee_benefits, :name_values

  def test_create_0
    @emp_bene = EmployeeBenefit.new :employee_id => 1

    @emp_bene.eff_year = 2001
    @emp_bene.eff_month = 12
    assert !@emp_bene.save
    assert !@emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
    assert !@emp_bene.errors.invalid?('employee_id')
  	assert_equal @emp_bene.errors.on(:employee_id), nil
    assert !@emp_bene.errors.invalid?('deposited_at')
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
    assert @emp_bene.errors.invalid?('eff_month')
  	assert_equal @emp_bene.errors.on(:eff_month), 'Error - current package effective month does not match current record.'
    assert !@emp_bene.errors.invalid?('employee_package_id')
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
    assert !@emp_bene.errors.invalid?('employee_id')
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 1")
  	assert_equal @rec_count, 1
  end

  def test_create_1
    @emp_bene = EmployeeBenefit.new :employee_id => 1
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 1
    @emp_bene.employee_package_id = @cur_pkg.id

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 1")
  	assert_equal @rec_count, 2
  end

  def test_create_2
    @emp_bene = EmployeeBenefit.new :employee_id => 2
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_equal @cur_pkg, nil
    #assert_equal @cur_pkg.id, 1
    #@emp_bene.employee_package_id = @cur_pkg.id

    assert !@emp_bene.save
    assert !@emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), 'Error - cannot find employee (or is deactivated).'
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_not_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 2")
  	assert_equal @rec_count, 1
  end

  def test_create_3
    @emp_bene = EmployeeBenefit.new :employee_id => 13
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 5
    @emp_bene.employee_package_id = @cur_pkg.id

    assert !@emp_bene.save
    assert !@emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), 'Error - cannot find employee (or is deactivated).'
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 13")
  	assert_equal @rec_count, 0
  end

  def test_create_4
    @emp_bene = EmployeeBenefit.new :employee_id => 14
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 6
    @emp_bene.employee_package_id = @cur_pkg.id

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 14")
  	assert_equal @rec_count, 1
  end

  def test_create_5
    @emp_bene = EmployeeBenefit.new :employee_id => 15
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 8
    @emp_bene.employee_package_id = @cur_pkg.id

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 15")
  	assert_equal @rec_count, 1
  end

  def test_create_6
    @emp_bene = EmployeeBenefit.new :employee_id => 16
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 10
    @emp_bene.employee_package_id = @cur_pkg.id

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 16")
  	assert_equal @rec_count, 1
  end

  def test_create_7
    @emp_bene = EmployeeBenefit.new :employee_id => 17
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 12
    @emp_bene.employee_package_id = @cur_pkg.id

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 17")
  	assert_equal @rec_count, 1
  end

  def test_create_8
    @emp_bene = EmployeeBenefit.new :employee_id => 18
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 15
    @emp_bene.employee_package_id = @cur_pkg.id

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 18")
  	assert_equal @rec_count, 1
  end

  def test_create_9
    @emp_bene = EmployeeBenefit.new :employee_id => 19
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_equal @cur_pkg, nil
    #assert_equal @cur_pkg.id, 15
    #@emp_bene.employee_package_id = @cur_pkg.id

    assert !@emp_bene.save
    assert !@emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_not_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#@emp_bene.reload
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 19")
  	assert_equal @rec_count, 0
  end

  def test_destroy_1
	num_employee_benefits = EmployeeBenefit.count

    @emp_bene = EmployeeBenefit.find(:first, :conditions => "id = 1")
    assert_not_nil @emp_bene
  	assert_equal @emp_bene.deposited_at, nil
  	assert @emp_bene.destroy
  	assert_equal @emp_bene.errors.count, 0
    assert_equal num_employee_benefits - 1, EmployeeBenefit.count
  end

  def test_destroy_2
	num_employee_benefits = EmployeeBenefit.count

    @emp_bene = EmployeeBenefit.find(:first, :conditions => "id = 2")
    assert_not_nil @emp_bene
  	assert_not_equal @emp_bene.deposited_at, nil
  	assert !@emp_bene.destroy
  	assert_equal @emp_bene.errors.count, 1
  	assert_equal @emp_bene.errors.on(:deposited_at), 'Error - cannot delete deposited benefit.'
    assert_equal num_employee_benefits, EmployeeBenefit.count
  end

  def test_tests_1_deposits

     @emp_bene = EmployeeBenefit.new :employee_id => 1
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 1
    @emp_bene.employee_package_id = @cur_pkg.id
    @emp_bene.reg_hours = 1
    @emp_bene.ot_hours = 2
    @emp_bene.monthly_benefit = 33.33
    @emp_bene.deposit = 12.34
    @emp_bene.deposited_at = Time.now

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 1")
  	assert_equal @rec_count, 2

  	@emp_bene.reload
  	assert_equal @emp_bene.deposit, 12.34

     @emp_bene = EmployeeBenefit.new :employee_id => 1
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 1
    @emp_bene.employee_package_id = @cur_pkg.id
    @emp_bene.reg_hours = 3
    @emp_bene.ot_hours = 4
    @emp_bene.monthly_benefit = 55.55
    @emp_bene.deposit = 23.45
    #@emp_bene.deposited_at = Time.now

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 1")
  	assert_equal @rec_count, 3

  	@emp_bene.reload
  	assert_equal @emp_bene.deposit, -5.76

     @emp_bene = EmployeeBenefit.new :employee_id => 1
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 1
    @emp_bene.employee_package_id = @cur_pkg.id
    @emp_bene.reg_hours = 7
    @emp_bene.ot_hours = 3
    @emp_bene.monthly_benefit = 99.99
    @emp_bene.deposit = 34.56
    @emp_bene.deposited_at = Time.now
  	assert_equal @emp_bene.deposit, 34.56

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 1")
  	assert_equal @rec_count, 4

  	#assert_equal @emp_bene.deposit, 34.56
  	assert_equal @emp_bene.deposit, 17.69
  	@emp_bene.reload
  	assert_equal @emp_bene.deposit, 17.69
  	
    assert_not_nil @emp_bene
  	#assert_equal @emp_bene.id, 1
  	assert_equal @emp_bene.employee_id, 1
  	assert_equal @emp_bene.eff_month, 4
  	assert_equal @emp_bene.eff_year, 2006
    assert_equal @emp_bene.employee_package_id, @cur_pkg.id
    assert_equal @cur_pkg.id, 1

    @emp_pdeps = @emp_bene.get_pending_deposits
    assert_equal @emp_pdeps.length, 1
    assert_equal @emp_pdeps[0].id, 1
    assert_equal @emp_pdeps[0].deposit, 77.72
    assert_equal @emp_pdeps[0].eff_month, 1
    assert_equal @emp_pdeps[0].dep_eff_year, 2006
    assert_equal @emp_pdeps[0].dep_eff_month, 4
    assert_equal @emp_pdeps[0].dep_eff_year, 2006
    
    assert_equal @emp_bene.tot_pending_deposits(''), 77.72

  	assert_equal @emp_bene.deposit, 17.69
  	assert_not_equal @emp_bene.deposited_at, nil
  	
  	@emp_deps = @emp_bene.get_deposits_made
    assert_equal @emp_deps.length, 1
    assert_not_equal @emp_deps[0].deposited_at, nil
    assert_equal @emp_deps[0].eff_month, 4
    assert_equal @emp_deps[0].dep_eff_year, 2006
    assert_equal @emp_deps[0].dep_eff_month, 4
    assert_equal @emp_deps[0].dep_eff_year, 2006
    assert_equal @emp_deps[0].reg_hours, 1
    assert_equal @emp_deps[0].ot_hours, 2
    assert_equal @emp_deps[0].monthly_benefit, 33.33
    assert_equal @emp_deps[0].deposit, 12.34
    
    assert_equal @emp_bene.tot_deposits_made, 30.03
    
    EmployeeBenefit.make_cur_deposit

    assert_equal @emp_bene.tot_deposits_made, 24.27
    
  end
  
  def test_tests_2
    @emp_bene = EmployeeBenefit.new :employee_id => 1
    assert_not_equal @emp_bene, nil
    @cur_pkg = @emp_bene.current_package
    assert_not_equal @cur_pkg, nil
    assert_equal @cur_pkg.id, 1
    @emp_bene.employee_package_id = @cur_pkg.id
    @emp_bene.reg_hours = 11.5
    @emp_bene.ot_hours = 22.5
    @emp_bene.hourly_benefit = 5.0
    @emp_bene.monthly_benefit = 345.67
    @emp_bene.deposit = 112.34    #this is recalculated  where??
    #@emp_bene.deposited_at = Time.now

    assert @emp_bene.save
    assert @emp_bene.errors.empty?
  	assert_equal @emp_bene.errors.on(:id), nil
  	assert_equal @emp_bene.errors.on(:employee_id), nil
  	assert_equal @emp_bene.errors.on(:deposited_at), nil
  	assert_equal @emp_bene.errors.on(:eff_month), nil
  	assert_equal @emp_bene.errors.on(:employee_package_id), nil
  	#@emp_bene.update
  	#assert_equal @emp_bene.eff_month, 12
  	@rec_count = EmployeeBenefit.count("employee_id = 1")
  	assert_equal @rec_count, 2

  	@emp_bene.reload
  	
    assert_not_nil @emp_bene
  	#assert_equal @emp_bene.id, 1
  	assert_equal @emp_bene.employee_id, 1
  	assert_equal @emp_bene.eff_month, 4
  	assert_equal @emp_bene.eff_year, 2006
    assert_equal @emp_bene.employee_package_id, @cur_pkg.id
    assert_equal @cur_pkg.id, 1
    
    assert_equal @emp_bene.hourly_benefit, 5.00
    assert_equal sprintf( "%.4f", @emp_bene.current_package.calc_hourly_benefit), '6.9957'
    assert_equal @emp_bene.calc_tot_hours, 34.0
    assert_equal @emp_bene.monthly_benefit, 345.67
    assert_equal @emp_bene.tot_current_benefit, 237.85
    assert_equal @emp_bene.tot_deposits_made, 0.00
    assert_equal @emp_bene.deposit, 107.82
    
    assert_equal @emp_bene.is_current, true
    assert_equal @emp_bene.is_pending, false
    assert_equal @emp_bene.is_pending_selected, false
    assert_equal @emp_bene.is_deposit_out_of_bal, false
    assert_equal @emp_bene.is_benefit_out_of_bal, false
    assert_equal @emp_bene.is_benefit_changed, true
    
    @emp_bene.hourly_benefit = 6.9957
    assert @emp_bene.save
    @emp_bene.reload
    assert_equal sprintf( "%.4f", @emp_bene.current_package.calc_hourly_benefit), '6.9957'
    assert_equal @emp_bene.current_package.id, @emp_bene.employee_package_id
    assert_equal @emp_bene.is_benefit_changed, false

    end


end
