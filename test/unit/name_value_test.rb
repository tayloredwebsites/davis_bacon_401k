require 'test_helper'

class NameValueTest < ActiveSupport::TestCase
  include NumberHandling

  fixtures :name_values

  def test_allowed_name_values_0_dont_allow_nil_value
    num_name_values = NameValue.count
    @val = NameValue.new

    @val.val_name = '2'
    @val.val_value = nil
    @val.save
    #assert @val.errors.empty?
    assert_equal [], @val.errors['val_name']
    assert_equal ["Nil value not allowed."], @val.errors['val_value']
    #assert_equal "can't be blank", @val.errors.on(:val_value)
    # error came from #validates_presence_of :val_value in name_value.rb

    @two = NameValue.where("val_name = '2'")
    assert_equal 0, @two.count

    assert_equal num_name_values, NameValue.count
  end

  def test_allowed_name_values_1_allow_empty_value
    num_name_values = NameValue.count
    @val = NameValue.new

    @val.val_name = '2'
    @val.val_value = ''
    @val.save
    assert @val.errors.empty?

    isthere = NameValue.where("val_name = '2'")
    assert_equal 1, isthere.count

    assert_equal num_name_values+1, NameValue.count
  end

  def test_allowed_name_values_2
    num_name_values = NameValue.count
    @val = NameValue.new

    @val.val_name = '2'
    @val.val_value = 'two'
    assert @val.save
    #@val.save
    #assert @val.errors.empty?
    assert_equal [], @val.errors['val_name']
    assert_equal [], @val.errors['val_value']
  	#assert_equal "can't be blank", @val.errors.on(:val_value)

    @twos = NameValue.where("val_name = '2'")
    assert_not_equal 0, @twos.count
    @two = @twos.first
    assert_not_nil @two
    assert_equal @two.val_name, "2"
    assert_equal @two.val_value, "two"

    assert_equal num_name_values+1, NameValue.count
  end

  def test_disallowed_name_values

		@too_large_name = "hugehugehugehugehugehugehugehugehugehugehuge"
		@too_large_value = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"

    @val = NameValue.new

    @val.val_name = @val.val_value = ''
    assert !@val.save
    assert_equal ["is too short (minimum is 1 character)"], @val.errors['val_name']

    @val.val_name = @too_large_name
    @val.val_value = ''
    assert !@val.save
    assert_equal ["is too long (maximum is 40 characters)"], @val.errors['val_name']

    @val.val_name = '1'
    @val.val_value = @too_large_value
    assert !@val.save
    assert_equal ["Length of value too long"], @val.errors['val_value']

	end

  def test_get_accounting_month
  	@val = NameValue.where(val_name: 'accounting_month').first
    assert_equal @val.val_name, 'accounting_month'
    assert_equal @val.val_value, '4'

    # test_var = NameValue.where("val_name = ?", 'accounting_month')
    # assert_equal test_var.val_value, '4'

    assert_equal NameValue.get_accounting_month, '4'
  end

  def test_get_accounting_year
    assert_equal NameValue.get_accounting_year, '2006'
  end


  def test_get_val_1
    @val = NameValue.get_val('accounting_month')
    assert_equal @val, '4'
  end

  def test_get_val_2
    @val = NameValue.get_val('accounting_mon')
    #assert @val.errors.invalid?('get_val')
    assert_equal @val.blank?, true
  end


  def test_set_accounting_month_0
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'

  	NameValue.set_accounting_month
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'
  end

  def test_set_accounting_month_1
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'

  	NameValue.set_accounting_month(nil,nil)
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'
  end

  def test_set_accounting_month_2
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'

  	NameValue.set_accounting_month('2006','4')
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'
  end

  def test_set_accounting_month_3
  	@got_month = NameValue.get_val('accounting_month')
  	@got_year = NameValue.get_val('accounting_year')
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2006'

  	#assert_equal NameValue.get_accounting_month, '2005'
  	#assert_equal NameValue.get_accounting_year, '4'

  	assert_equal NameValue.set_accounting_month('2005','5'), ''
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	assert_equal @got_month, '5'
  	assert_equal @got_year, '2005'

  	assert_equal NameValue.set_accounting_month('2005','4'), ''
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2005'
  end

  def test_set_accounting_month_4
   	NameValue.set_accounting_month(:cur_month => '5', :cur_year => '2006')
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	#assert_equal @got_month, '5'
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2005'	#note values saved in class hash
	end

  def test_set_accounting_month_5
   	NameValue.set_accounting_month(:cur_year => '2006', :cur_month => '5')
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	#assert_equal @got_month, '5'
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2005'	#note values saved in class hash
	end

  def test_set_accounting_month_6
   	NameValue.set_accounting_month :cur_month => '5', :cur_year => '2006'
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	#assert_equal @got_month, '5'
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2005'	#note values saved in class hash
	end

  def test_set_accounting_month_7
   	NameValue.set_accounting_month :cur_year => '2006', :cur_month => '5'
  	@got_month = NameValue.get_accounting_month
  	@got_year = NameValue.get_accounting_year
  	#assert_equal @got_month, '5'
  	assert_equal @got_month, '4'
  	assert_equal @got_year, '2005'	#note values saved in class hash
	end

end
