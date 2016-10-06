require File.dirname(__FILE__) + '/../test_helper'
require 'employee_package_controller'

# Re-raise errors caught by the controller.
class EmployeePackageController; def rescue_action(e) raise e end; end

class EmployeePackageControllerTest < Test::Unit::TestCase
	fixtures :employees, :employee_packages, :employee_benefits

  def setup
    @controller = EmployeePackageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # duplicate of test_create_2
  # def test_create_1
  #   num_employee_packages = EmployeePackage.count
  #   get :create, :employee_package => {}
  #   assert_equal flash[:notice], 'Error - need employee id to create employee package'
  #   assert_response :redirect
  #   assert_redirected_to :action => 'list'
  #   assert_equal num_employee_packages, EmployeePackage.count
  # end

  def test_create_2
    num_employee_packages = EmployeePackage.count
    post :create, :employee_package => {}
    assert_equal flash[:notice], 'Error - need employee id to create employee package'
    assert_response :redirect
    assert_redirected_to :controller => 'employee', :action => 'list'
    assert_equal num_employee_packages, EmployeePackage.count
  end

  def test_create_3
    num_employee_packages = EmployeePackage.count
    post :create, :employee_package => {:employee_id => "1", :eff_month => "12", :eff_year => "2005"}
    assert_equal flash[:notice], 'EmployeePackage was successfully created.'
    assert_response :redirect
    assert_redirected_to :controller => 'employee', :action => 'edit'
    assert_equal num_employee_packages + 1, EmployeePackage.count
  end

  def test_edit
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_equal flash[:notice], ''
    assert_not_nil assigns(:employee_package)
    assert_equal assigns(:employee_package).employee_id, 1
    #assert assigns(:employee_package).valid?
  end

  def test_index
    get :index
    assert_equal flash[:notice], ''
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list
    assert_equal flash[:notice], ''
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:employee_packages)
  end

  def test_new_1
    get :new
    assert_not_equal flash[:notice], ''
    assert_response :redirect
    assert_redirected_to :controller => 'employee', :action=> 'list'
  end

  def test_new_2
    get :new, :employee_id => 1
    assert_equal flash[:notice], ''
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:employee_package)
  end

  def test_show
    get :show, :id => 1

    assert_equal flash[:notice], ''
    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:employee_package)
    assert_equal assigns(:employee_package).employee_id, 1
    #assert assigns(:employee_package).valid?
  end

  def test_update_1
    num_employee_packages = EmployeePackage.count
    get :update, :employee_package => {}
    assert_equal flash[:notice], ''
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal num_employee_packages, EmployeePackage.count
  end

  def test_update_2
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_equal flash[:notice], ''
    assert_not_nil assigns(:employee_package)
    assert_equal assigns(:employee_package).employee_id, 1
    assert assigns(:employee_package).valid?
    assert_equal assigns(:employee_package).monthly_medical, 811.26

    @emp_package = EmployeePackage.find(:first, :conditions => "id = '2'")
    post :update,
	    :id => @emp_package.id,
	    :employee_package =>
	    {
	    	#:id => @emp_package.id,
	    	#:employee_id => @emp_package.employee_id,
	    	#:hourly_wage => @emp_package.hourly_wage,
	    	:monthly_medical => 669.69,
	    	#:annual_sick => @emp_package.annual_sick,
	    	#:annual_holiday => @emp_package.annual_holiday,
	    	#:annual_vacation => @emp_package.annual_vacation,
	    	#:annual_personal => @emp_package.annual_personal,
	    	#:eff_month => @emp_package.eff_month,
	    	#:eff_year => @emp_package.eff_year
	    }
    assert_equal flash[:notice], ''
    assert_response :redirect
    assert_redirected_to :controller => 'employee', :action => 'view', :id => 2
    #assert_template 'show'

    assert_not_nil assigns(:employee_package)
    assert assigns(:employee_package).valid?
    assert_equal assigns(:employee_package).monthly_medical,669.69
    assert_equal assigns(:employee_package).hourly_wage,27.6

    @emp_package = EmployeePackage.find(:first, :conditions => "id = '2'")
    assert_equal @emp_package.monthly_medical,669.69

    @test_employee_package = EmployeePackage.find(2)
    assert_not_nil @test_employee_package
    assert_equal @test_employee_package.monthly_medical,669.69

  end

end
