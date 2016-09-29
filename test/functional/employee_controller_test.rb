require File.dirname(__FILE__) + '/../test_helper'
require 'employee_controller'

# Re-raise errors caught by the controller.
class EmployeeController; def rescue_action(e) raise e end; end

class EmployeeControllerTest < Test::Unit::TestCase
	fixtures :employees, :employee_packages, :employee_benefits, :name_values

  def setup
    @controller = EmployeeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_1
    num_employees = Employee.count

    get :create, :employee => {}

    assert_response :redirect
    assert_redirected_to :action => 'new'

    assert_equal num_employees, Employee.count
  end

  def test_create_2
    num_employees = Employee.count

    post :create, :employee => {}

    assert_not_equal flash[:notice], ''
    assert_response :success
    assert_template 'new'

    assert_equal num_employees, Employee.count
  end

  def test_create_3
    num_employees = Employee.count

    post :create, 'id' => '3', :employee => {
    		:id => '3',
    		:emp_id => '23',
    		:last_name => "something",
    		:first_name => "something",
    		:ssn => "123456777",
    	}

    assert_equal flash[:notice], 'Employee was successfully created.'
    assert_response :redirect
    assert_redirected_to :action => 'view'

    assert_equal num_employees + 1, Employee.count
  end

  def test_deactivate_1
    @employee = Employee.find(1)
    assert_not_nil @employee
    assert_equal @employee.deactivated,0

    post :deactivate, :id => 1
    assert_equal flash[:notice], 'Employee was successfully deactivated.'
    assert_response :redirect
    assert_redirected_to :action => 'list'

    @test_emp = Employee.find(1)
    assert_not_nil @test_emp
    assert_equal @test_emp.deactivated,1
  end

  def test_destroy_1
    assert_not_nil Employee.find(1)

    post :destroy, :id => 1
    assert_equal flash[:notice], 'Delete feature disabled, must deactivate user'
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #assert_raise(ActiveRecord::RecordNotFound) {
    #  Employee.find(1)
    #}

    assert_not_nil Employee.find(1)
  end

  def test_destroy_2
    assert_not_nil Employee.find(13)

    post :deactivate, :id => 13
    assert_equal flash[:notice], 'Employee was successfully deactivated.'
    assert_response :redirect
    assert_redirected_to :action => 'list'

    @test_emp = Employee.find(13)
    assert_equal flash[:notice], 'Employee was successfully deactivated.'
    assert_not_nil @test_emp
    assert_equal @test_emp.deactivated,1

    post :destroy, :id => 13
    assert_equal flash[:notice], "user O'Connell, Thomas  ,  deleted"
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Employee.find(13)
    }

  end

  def test_edit
    get :edit, :id => 1

    assert_equal flash[:notice], nil
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:employee)
    assert assigns(:employee).valid?
  end

  def test_index
    get :index
    assert_equal flash[:notice], nil
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_equal flash[:notice], nil
    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:employees)
  end

  def test_new
    get :new

    assert_equal flash[:notice], nil
    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:employee)
  end

  def test_show
    get :show, :id => 1

    assert_equal flash[:notice], nil
    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:employee)
    assert assigns(:employee).valid?
  end

  def test_update_1
    num_employees = Employee.count

    get :update, :employee => {}

    assert_equal flash[:notice], nil
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_employees, Employee.count
  end

  def test_update_2
    get :edit, :id => 1

    assert_equal flash[:notice], nil
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:employee)
    assert assigns(:employee).valid?
    assert_equal assigns(:employee).last_name,'Pekoske'

    post :update, :id => 1, :employee => {:last_name => 'Taylor'}
    assert_equal flash[:notice], nil
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
    #assert_template 'show'

    assert_not_nil assigns(:employee)
    assert assigns(:employee).valid?
    assert_equal assigns(:employee).last_name,'Taylor'

    @test_employee = Employee.find(1)
    assert_not_nil @test_employee
    assert_equal @test_employee.last_name,'Taylor'

  end


end
