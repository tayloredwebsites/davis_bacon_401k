
    if ! defined? @@saved_values
      @@saved_values = Hash.new
    end
    if ! defined? @@default_values
      @@default_values = { "accounting_month" => "1", "accounting_year" => "2001", "start_year" => "2005" }
    end

class NameValue < ActiveRecord::Base

	# set default current month
#	@@accounting_month = nil
#	@@accounting_year = nil
#	@@start_year = nil

	# have cached values for performance
#	if @@saved_values == nil
#	   @@saved_values = Hash.new
#	end

	# have default values if not defined yet
#	if @@default_values == nil
#	   @@default_values = { "accounting_month" => "1", "accounting_year" => "2001", "start_year" => "2005" }
#    end

	#attr_accessor :val_name, :val_value

	attr_accessor :cur_year, :cur_month

	# when getting name value pairs, save the values in hash to avoid db calls
	# if not defined, use value in default values hash (if available)
	def self.get_val(the_name)
		@name_val = self.new :val_name => the_name
		if @@saved_values.has_key?(@name_val.val_name)
			@name_val.val_value = @@saved_values[@name_val.val_name]
		else
			@lu_name_val = NameValue.find(:first, :conditions => ["val_name = ?", the_name])
			if @lu_name_val && @lu_name_val.val_value
				@name_val = @lu_name_val
				@@saved_values[@name_val.val_name] = @name_val.val_value
			else
				# not found in either saved values or in name_value table, see if default exists
				if @@default_values.has_key?(@name_val.val_name)
					@name_val.val_value = @@default_values[@name_val.val_name]
					# value not kept in saved values, so it will be looked up in table for update
				else
				end
			end
		end
    @name_val.val_value
	end

	# when updating name value pairs, used save the values in hash to avoid db calls
	def update
		if super
			@@saved_values[self.val_name] = self.val_value
		end
		self
	end


	# convenience method to get the accounting month
	def self.get_accounting_month
		self.get_val('accounting_month')
	end

	# convenience method to get the accounting year
	def self.get_accounting_year
		self.get_val('accounting_year')
	end

	# set the current accounting month for the application, requires records to exist in database
	def self.set_accounting_month(cur_year=nil, cur_month=nil)
		@done = ''
		if cur_month == nil || cur_year == nil
			@done = 'nil month or year'
		else
			@name_value = self.new :cur_year => cur_year, :cur_month => cur_month
			# start with current values, then attempt update within transaction
	    val_month_work = self.find(:first, :conditions => ["val_name = 'accounting_month'"])
	    val_year_work = self.find(:first, :conditions => ["val_name = 'accounting_year'"])
	    if val_month_work && val_year_work
				@@saved_values['accounting_month']
				#if cur_month != @@accounting_month || cur_year != @@accounting_year
				if cur_month != @@saved_values['accounting_month'] || cur_year != @@saved_values['accounting_year']
					# update both records in transaction
					@done = 'start transaction error'
					self.transaction()  do
						@done = 'set month value error'
						val_month_work.val_name = 'accounting_month'
						val_month_work.val_value = cur_month
						@done = 'save month error'
						val_month_work.save!
						@done = 'set year value error'
						val_month_work.val_name = 'accounting_year'
						val_year_work.val_value = cur_year
						@done = 'save year error'
						val_year_work.save!
						@done = ''
					end
			    #@done += ", set to " + val_month_work.val_value + "/" + val_year_work.val_value
			    val_month_work = self.find(:first, :conditions => ["val_name = 'accounting_month'"])
			    val_year_work = self.find(:first, :conditions => ["val_name = 'accounting_year'"])
					@@saved_values[val_month_work.val_name] = val_month_work.val_value
					@@saved_values[val_year_work.val_name] = val_year_work.val_value
			    #@done += ", set to " + @@saved_values[val_month_work.val_name] + "/" + @@saved_values[val_year_work.val_name]
				else
					# no changes - nothing to do
					@done = ''
				end
			else
				@done = 'missing accounting_month or accounting_year in database'
			end
		end
		@done	# completed all code in transaction flag
	end

  validates_uniqueness_of :val_name, :on => :create
  validates_length_of :val_name, :within => 1..40

  #validates_presence_of :val_value
  validates_length_of :val_value, :within => 0..255

end
