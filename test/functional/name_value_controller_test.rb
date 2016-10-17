require 'test_helper'
# require 'name_value_controller'

# Re-raise errors caught by the controller.
# class NameValueController; def rescue_action(e) raise e end; end

class NameValueControllerTest < ActionController::TestCase
  include NumberHandling
  def setup
    @controller = NameValueController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


  def test_accounting_month_1

    get :accounting_month

    assert_response :success
    assert_template 'accounting_month'

    assert_equal '4', NameValue.get_accounting_month
    assert_equal '2006', NameValue.get_accounting_year

    #assert_equal @name_value.get_accounting_month, NameValue.get_accounting_month
    #assert_equal @name_value.get_accounting_year, NameValue.get_accounting_year

    #assert_equal @accounting_month, NameValue.get_accounting_month
    #assert_equal @accounting_year, NameValue.get_accounting_year

  end

  def test_accounting_month_2

    get :accounting_month

    assert_response :success
    assert_template 'accounting_month'

    @save_month = @accounting_month
    @save_year = @accounting_year

    post :accounting_month, :select_year => '2005', :select_month => '5'
    assert_response :success
    assert_template 'accounting_month'
    assert_equal flash[:notice], ''


    assert_equal NameValue.get_accounting_month, '5'
    assert_equal NameValue.get_accounting_year, '2005'

    #assert_equal @accounting_month, '5'
    #assert_equal @accounting_year, '2005'


  end

  def test_create_1
    num_name_values = NameValue.count

    get :create, :name_value => {}

    assert_response :redirect
    assert_redirected_to :action => 'new'

    assert_equal num_name_values, NameValue.count
  end

  def test_create_2
    num_name_values = NameValue.count

    post :create, :name_value => {}

    assert_response :success
    assert_template 'new'

    assert_equal num_name_values, NameValue.count
  end

  def test_create_3
    num_name_values = NameValue.count

    post :create, :name_value => {:val_name => "testvar", :val_value => "something"}

    assert_response :redirect
    assert_redirected_to :action => 'view', :id => 1000004

    assert_equal num_name_values + 1, NameValue.count
  end

  def test_edit
    get :edit, :id => 1000001

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:name_value)
    assert assigns(:name_value).valid?
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:name_values)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:name_value)
  end

  def test_show
    get :show, :id => 1000001

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:name_value)
    assert assigns(:name_value).valid?
  end

  def test_update_1
    num_name_values = NameValue.count

    get :update, :name_value => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_name_values, NameValue.count
  end

  def test_update_2
    get :edit, :id => 1000001

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:name_value)
    assert assigns(:name_value).valid?
    assert_equal assigns(:name_value).val_value,'4'

    post :update, :id => 1000001, :name_value => {:val_value => '5'}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1000001
    #assert_template 'show'

    assert_not_nil assigns(:name_value)
    assert assigns(:name_value).valid?
    assert_equal assigns(:name_value).val_value,'5'

    @test_name_value = NameValue.find(1000001)
    assert_not_nil @test_name_value
    assert_equal @test_name_value.val_value,'5'

  end


end
