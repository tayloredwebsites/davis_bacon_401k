require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  include NumberHandling

	fixtures :employees, :employee_packages, :employee_benefits, :name_values

  def test_allowed_employees_1
		num_employees = Employee.count

    @emp = Employee.new
    @emp.id = '3'
    @emp.emp_id = '23'
    @emp.last_name = ''
    @emp.first_name = 'Dave'
    @emp.ssn = '123456789'
    assert !@emp.save
    #assert @emp.errors.empty?
  	assert_equal ["is too short (minimum is 1 character)"], @emp.errors[:last_name]
  	# error came from #validates_presence_of :last_name in employee.rb
    assert_equal [], @emp.errors['id']

    @three = Employee.where(id: 3)
    assert_equal 0, @three.count

    assert_equal num_employees, Employee.count
  end

  def test_allowed_employees_2
		num_employees = Employee.count

    @emp = Employee.new
    @emp.id = '3'
    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = 'Dave'
    @emp.ssn = '123456789'
    #assert @emp.save
    @emp.save
    assert !@emp.errors.empty?
    assert_equal ["has already been taken"], @emp.errors['ssn']

    assert_equal num_employees, Employee.count
  end

  def test_allowed_employees_3
	 num_employees = Employee.count

    @emp = Employee.new
    @emp.id = 3
    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = 'Dave'
    @emp.ssn = '123456780'
    @emp.save
    assert @emp.errors.empty?

    @three = Employee.find(3)
    assert_not_nil @three
    assert_equal @three.id, 3
    assert_equal @three.last_name, "three"
    assert_equal @three.first_name, 'Dave'
    assert_equal @three.ssn, '123456780'

    assert_equal num_employees + 1, Employee.count
  end

  def test_allowed_employees_4
		num_employees = Employee.count

		@too_large_name = "hugehugehugehugehugehugehugehugehugehugehuge"

    @emp = Employee.new
    @emp.emp_id = '23'
    @emp.last_name = ''
    @emp.first_name = 'Dave'
    @emp.ssn = '123456789'
    assert !@emp.save
    assert_equal ["is too short (minimum is 1 character)"], @emp.errors['last_name']

    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = ''
    @emp.ssn = '123456789'
    assert !@emp.save
    assert_equal ["is too short (minimum is 1 character)"], @emp.errors['first_name']

    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = 'Dave'
    @emp.ssn = '12345678'
    assert !@emp.save
    assert_equal ["is the wrong length (should be 9 characters)"], @emp.errors['ssn']

    @emp.emp_id = '23'
    @emp.last_name = @too_large_name
    @emp.first_name = 'Dave'
    @emp.ssn = '123456789'
    assert !@emp.save
    # assert @emp.errors.invalid?('last_name')
    assert_equal ["is too long (maximum is 40 characters)"], @emp.errors['last_name']

    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = @too_large_name
    @emp.ssn = '123456789'
    assert !@emp.save
    # assert @emp.errors.invalid?('first_name')
    assert_equal ["is too long (maximum is 40 characters)"], @emp.errors['first_name']

    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = 'Dave'
    @emp.ssn = '1234567890'
    assert !@emp.save
    # assert @emp.errors.invalid?('ssn')
    assert_equal ["has already been taken", "is the wrong length (should be 9 characters)"], @emp.errors['ssn']

    assert_equal num_employees, Employee.count

	end

  def test_allowed_employees_duplicate
		num_employees = Employee.count

		@emp = Employee.new
    @emp.id = '2'
    @emp.emp_id = '23'
    @emp.last_name = 'three'
    @emp.first_name = 'Dave'
    @emp.ssn = '123456789'
    assert !@emp.save
    assert !@emp.errors.empty?
    assert_equal ["has already been taken"], @emp.errors['ssn']

    assert_equal num_employees, Employee.count
  end

  def test_destroy_active
    num_employees = Employee.count
  	@employee = Employee.find(1)
  	assert_equal @employee.deactivated, 0	# active
  	@employee.destroy
  	assert @employee.errors.count > 0
  	assert_equal ['cannot destroy active record 2'], @employee.errors[:deactivated]
    assert_equal num_employees, Employee.count
  end

  def test_destroy_deactivated_1
    num_employees = Employee.count
  	@employee = Employee.find(2)
  	assert_equal @employee.deactivated, 1	# deactivated
  	@employee.destroy
  	assert @employee.errors.count > 0
  	assert_equal ['Error - cannot delete, employee has benefits recorded 2'], @employee.errors[:id]
    assert_equal num_employees, Employee.count
  end

  def test_destroy_deactivated_2
    num_employees = Employee.count
  	@employee = Employee.find(20)
  	assert_equal @employee.deactivated, 1	# deactivated
  	@employee.destroy
  	#assert_equal 'Error - cannot delete, employee has benefits recorded', @employee.errors.on(:id)
  	assert @employee.errors.count == 0
    assert_equal num_employees - 1, Employee.count
  end

  def test_deactivate
  	@employee = Employee.find(1)
  	assert_equal @employee.deactivated, 0	# active
  	@employee.deactivate
  	@employee.save
  	@employee.reload
  	assert_equal @employee.deactivated, 1	# deactivated
  end

  def test_reactivate
  	@employee = Employee.find(2)
  	assert_equal @employee.deactivated, 1	# deactivated
  	@employee.reactivate
  	@employee.save
  	@employee.reload
  	assert_equal @employee.deactivated, 0	# reactivated
  end


end
