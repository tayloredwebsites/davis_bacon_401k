require File.dirname(__FILE__) + '/../test_helper'

class NameValueTest < Test::Unit::TestCase
  fixtures :name_values


  def test_allowed_name_values_1

    @val = NameValue.new

    @val.val_name = '2'
    @val.val_value = ''
    #assert @val.save
    @val.save
    #assert @val.errors.empty?
    assert !@val.errors.invalid?('val_name')
    assert !@val.errors.invalid?('val_value')
  	#assert_equal "can't be blank", @val.errors.on(:val_value)
  	# error came from #validates_presence_of :val_value in name_value.rb

    @two = NameValue.find(:first, :conditions => "val_name = '2'")
    assert_not_nil @two
    assert_equal @two.val_name, "2"

  end

  def test_allowed_name_values_2

    @val = NameValue.new

    @val.val_name = '2'
    @val.val_value = 'two'
    assert @val.save
    #@val.save
    #assert @val.errors.empty?
    assert !@val.errors.invalid?('val_name')
    assert !@val.errors.invalid?('val_value')
  	#assert_equal "can't be blank", @val.errors.on(:val_value)

    @two = NameValue.find(:first, :conditions => "val_name = '2'")
    assert_not_nil @two
    assert_equal @two.val_name, "2"
    assert_equal @two.val_value, "two"

  end

  def test_disallowed_name_values

		@too_large_name = "hugehugehugehugehugehugehugehugehugehugehuge"
		@too_large_value = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"

    @val = NameValue.new

    @val.val_name = @val.val_value = ''
    assert !@val.save
    assert @val.errors.invalid?('val_name')

    @val.val_name = @too_large_name
    @val.val_value = ''
    assert !@val.save
    assert @val.errors.invalid?('val_name')

    @val.val_name = '1'
    @val.val_value = @too_large_value
    assert !@val.save
    assert @val.errors.invalid?('val_value')

	end

  def test_get_accounting_month
  	@val = NameValue.find(:first, :conditions => "val_name = 'accounting_month'")
    assert_equal @val.val_name, 'accounting_month'
    assert_equal @val.val_value, '4'

    test_var = NameValue.find(:first, :conditions => ["val_name = ?", 'accounting_month'])
    assert_equal test_var.val_value, '4'

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
    assert_equal @val, ''
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
