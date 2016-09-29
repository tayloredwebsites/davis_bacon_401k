# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def show_true_false (bool_field)
		if (bool_field != 0)
			'True'
		else
			'False'
		end
	end

	def get_month_options
		[
			['January', '1'],
			['February', '2'],
			['March', '3'],
			['April', '4'],
			['May', '5'],
			['June', '6'],
			['July', '7'],
			['August', '8'],
			['September', '9'],
			['October', '10'],
			['November', '11'],
			['December', '12']
		]
	end

	def get_year_options
		@time_now = Time.now
		@year_options = Array.new
		@start_year = NameValue.get_val("start_year")
		if @start_year
			@start_year = @start_year.to_i
		else
			@start_year = 2001
		end
		for yr in @start_year..(@time_now.year)
			@year_options.push([yr.to_s, yr.to_s])
		end
		@year_options.reverse
	end

	def nil_to_0(value)
		if value == nil
			0
		else
			value
		end
	end

	def round_money (value)
		((nil_to_0(value) * 100.0).round) / 100.0
	end

	def round_money_s (value)
		sprintf( "%.2f", nil_to_0(value) )
	end

	def round_places (value, places)
		_multiplier = 1.0
		places.times do |i|
			_multiplier *= 10
		end
		((nil_to_0(value) * _multiplier).round)	/ _multiplier
	end

	def round_places_s (value, places)
		sprintf( "%." + places.to_s + "f", round_places(nil_to_0(value), places))
	end

	def display_accounting_month
		NameValue.get_val("accounting_month") + "/" + NameValue.get_val("accounting_year")
	end

end
