
    if ! defined? @@saved_nv_values
      @@saved_nv_values = Hash.new
    end
    if ! defined? @@default_values
      @@default_values = { "accounting_month" => "1", "accounting_year" => "2001", "start_year" => "2005" }
    end

class NameValue < ActiveRecord::Base

  # set default current month
# @@accounting_month = nil
# @@accounting_year = nil
# @@start_year = nil

  # have cached values for performance
# if @@saved_nv_values == nil
#    @@saved_nv_values = Hash.new
# end

  # have default values if not defined yet
# if @@default_values == nil
#    @@default_values = { "accounting_month" => "1", "accounting_year" => "2001", "start_year" => "2005" }
#    end

  #attr_accessor :val_name, :val_value

  attr_accessor :cur_year, :cur_month, :val_name, :val_value

  # when getting name value pairs, save the values in hash to avoid db calls
  # if not defined, use value in default values hash (if available)
  def self.get_val(the_name)
    @name_val = self.new
    @name_val.val_name = the_name
    if @@saved_nv_values.has_key?(@name_val.val_name)
      Rails.logger.debug("*** @@saved_nv_values.has_key? #{the_name}: #{@@saved_nv_values[@name_val.val_name]}")
      @name_val.val_value = @@saved_nv_values[@name_val.val_name]
    else
      @lu_name_vals = NameValue.where(val_name: the_name)
      @lu_name_val = @lu_name_vals.present? ? @lu_name_vals.first : nil
      Rails.logger.debug("*** found @lu_name_val: #{@lu_name_val.inspect}")
      Rails.logger.debug("*** found @lu_name_val[:val_name]: #{@lu_name_val[:val_name]}")
      Rails.logger.debug("*** found @lu_name_val[:val_value]: #{@lu_name_val[:val_value]}")
      Rails.logger.debug("*** found @lu_name_val.val_name: #{@lu_name_val.val_name.inspect}")
      Rails.logger.debug("*** found @lu_name_val.val_value: #{@lu_name_val.val_value.inspect}")
      if @lu_name_val.present? && @lu_name_val[:val_value]
        @name_val = @lu_name_val
        @@saved_nv_values[@name_val[:val_name]] = @name_val[:val_value]
      else
        # not found in either saved values or in name_value table, see if default exists
        if @@default_values.has_key?(@name_val.val_name)
          Rails.logger.debug("*** @@default_values.has_key? #{the_name}: #{@@default_values[@name_val.val_name]}")
          @name_val.val_value = @@default_values[@name_val.val_name]
          # value not kept in saved values, so it will be looked up in table for update
        else
          Rails.logger.debug("*** cannot find value for #{the_name}")
        end
      end
    end
    @name_val.val_value
  end

  # when updating name value pairs, used save the values in hash to avoid db calls
  def update
    if super
      @@saved_nv_values[self.val_name] = self.val_value
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
      # val_month_work = self.find(:first, :conditions => ["val_name = 'accounting_month'"])
      # val_year_work = self.find(:first, :conditions => ["val_name = 'accounting_year'"])
      val_month_work = NameValue.where(val_name: 'accounting_month').first
      val_year_work = NameValue.where(val_name: 'accounting_year').first
      if val_month_work && val_year_work
        @@saved_nv_values['accounting_month']
        #if cur_month != @@accounting_month || cur_year != @@accounting_year
        if cur_month != @@saved_nv_values['accounting_month'] || cur_year != @@saved_nv_values['accounting_year']
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
          # val_month_work = self.find(:first, :conditions => ["val_name = 'accounting_month'"])
          # val_year_work = self.find(:first, :conditions => ["val_name = 'accounting_year'"])
          val_month_work = NameValue.where(val_name: 'accounting_month').first
          val_year_work = NameValue.where(val_name: 'accounting_year').first
          @@saved_nv_values[val_month_work.val_name] = val_month_work.val_value
          @@saved_nv_values[val_year_work.val_name] = val_year_work.val_value
          #@done += ", set to " + @@saved_nv_values[val_month_work.val_name] + "/" + @@saved_nv_values[val_year_work.val_name]
        else
          # no changes - nothing to do
          @done = ''
        end
      else
        @done = 'missing accounting_month or accounting_year in database'
      end
    end
    @done # completed all code in transaction flag
  end

  validates_uniqueness_of :val_name, :on => :create
  validates_length_of :val_name, :within => 1..40

  #validates_presence_of :val_value
  validates_length_of :val_value, :within => 0..255

end
