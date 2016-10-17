require 'test_helper'
# require 'employee_benefit_controller'

# Re-raise errors caught by the controller.
# class EmployeeBenefitController; def rescue_action(e) raise e end; end

class EmployeeBenefitControllerTest < ActionController::TestCase
  include NumberHandling
  def setup
    @controller = EmployeeBenefitController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
