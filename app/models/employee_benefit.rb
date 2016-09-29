class EmployeeBenefit < ActiveRecord::Base

  protected	## following methods will be protected

  before_create :create_timestamp

  # Properly set the current date and time in the created_at field on creation
  def create_timestamp
  	self.created_at = Time.now
  end

  before_destroy :validate_on_destroy

  # make sure record is deactivated before destroying
  def validate_on_destroy
  	true
  end

  before_save :prep_for_save

  def prep_for_save
  	# what about when doing the set deposited flag ????
		#		if @allow_edit
		#		 	@employee_benefit["deposit"] = round_money(@employee_benefit["monthly_benefit"] - tot_current_benefit)
		#		end
	 	self.deposit = self.monthly_benefit.to_f - self.tot_current_benefit.to_f - self.tot_deposits_made.to_f
		if self && !self.reg_hours
			self.reg_hours = 0.0
		end
		if self && !self.ot_hours
			self.ot_hours = 0.0
		end

	end

	public	## following methods will be public

  # to prevent destroys to records that have been deposited.
  def destroy
  	#if self.employee_deposited_at
  	if self.deposited_at
  		errors.add(:deposited_at, "Error - cannot delete deposited benefit.")
  		false
  	else
		super
  	end
  end


  # to prevent updates to records that have been deposited.
  def save
  	@is_ok = true

  	is_deposited = EmployeeBenefit.find(:first, :conditions => ["id = ? and deposited_at IS NOT NULL", self.id] )
  	if is_deposited != nil
  		errors.add(:deposited_at, "Error - cannot update benefit that has been already deposited.")
  		@is_ok = false
  	end
  	
  	@is_there = 0
  	if self.employee_id != nil
  	   @is_there = Employee.count( :all, :conditions => ["id = ? and deactivated = 0", self.employee_id] )
  	end
  	if @is_there < 1
  		errors.add(:employee_id, "Error - cannot find employee (or is deactivated).")
  		@is_ok = false
  	end

  	@this_pkg = nil
  	if self.employee_package_id != nil
  	   @this_pkg = EmployeePackage.find( :first, :conditions => ["id = ? and deactivated = 0", self.employee_package_id] )
  	end
  	if @this_pkg == nil
  		errors.add(:employee_package_id, "Error - cannot save without package .")
  		@is_ok = false
  	elsif @this_pkg.deactivated != 0
  		errors.add(:employee_package_id, "Error - current package is deactivated.")
  		@is_ok = false
  	elsif @this_pkg.eff_year > self.eff_year ||
  	       ( @this_pkg.eff_year == self.eff_year && @this_pkg.eff_month > self.eff_month )
  		errors.add(:eff_month, "Error - current package effective month does not match current record.")
  		@is_ok = false
  	end

    if @is_ok
      @is_ok = super
    end
    @is_ok
   end



  def initialize *args
  	super *args
#  	if self.employee_id == nil
#  		self.employee_id = args[0].to_i
#  	end
  	@employee = Employee.find(self.employee_id)
#  	if @employee != nil
#  		@employee_package = @employee.emp_latest_pkg
#  		if @employee_package != nil
#  			self.employee_package_id = @employee_package.id
#  			self.hourly_benefit = @employee_package.calc_hourly_benefit
#	  	else
#	  		errors.add(:employee_package_id, "Error - cannot find employee package id - " + @employee_package.id.to_s)
#	  	end
#  	else
#  		errors.add(:employee_id, "Error - cannot find employee for id " + self.employee_id)
#  	end
  	@emp_bene = nil
  	if self.id
  		@emp_bene = EmployeeBenefit.find(self.id)
  	end
  	if @emp_bene == nil
  		# new employee_benefit record, tread accordingly
	  	self.eff_month = NameValue.get_val("accounting_month")
	  	self.eff_year = NameValue.get_val("accounting_year")
	  	self.dep_eff_month = NameValue.get_val("accounting_month")
	  	self.dep_eff_year = NameValue.get_val("accounting_year")
	  	@emp_latest_bene = @employee.latest_benefit
	  	if @emp_latest_bene != nil && ! (args[0] && args[0]["ot_hours"])
	  		# if creating new benefit (not saving) with existing deposited benefit for month
	  		if @emp_latest_bene.deposited_at != nil
#breakpoint
		  		self.reg_hours = @emp_latest_bene.reg_hours
		  		self.ot_hours = @emp_latest_bene.ot_hours
		  		self.monthly_benefit = @emp_latest_bene.monthly_benefit
		  		#errors.add(:deposited_at, "Debugging - set deposited at from " + @emp_latest_bene.id.to_s)
		  	else
		  		errors.add(:deposited_at, "Error - Current record already exists for employee")
		  	end
	  	end
	  	if @employee != nil
	  		@employee_package = @employee.emp_latest_pkg
	  		if @employee_package != nil && @employee_package.id != nil
	  			self.employee_package_id = @employee_package.id
	  			self.hourly_benefit = @employee_package.calc_hourly_benefit
		  	else
		  		errors.add(:employee_package_id, "Error - cannot find employee package.")
		  	end
	  	else
	  		errors.add(:employee_id, "Error - cannot find employee for id " + self.employee_id.to_s)
	  	end
  	end

  	self
  end

	def calc_tot_hours
		tot_hours = 0.0
		if self && self.reg_hours
			tot_hours += self.reg_hours
		end
		if self && self.ot_hours
			tot_hours += self.ot_hours
		end
		tot_hours
	end

	def tot_current_benefit
		if self != nil && self.current_package != nil && self.current_package.calc_hourly_benefit != nil
			(self.calc_tot_hours * self.current_package.calc_hourly_benefit * 100.0).round / 100.0
		else
			0.00
		end
		# check ?
		#	( @employee_benefit["deposit"] -
		#		( @employee_benefit["monthly_benefit"] - @employee_benefit["tot_deposits_made"] )
		#	) > 0.005
	end

	def deposited_at_to_s
		if self.deposited_at != nil
			self.deposited_at.strftime("%Y-%m-%d %H:%M:%S")
		else
			''
		end
	end

#	def recalc_benefits
#		# get latest package for each employee record that is not deposited.
#		# current and pending look up based upon eff_month and eff_year (not dep_eff_*).
#		# update the package id (from latest package above).
#		update_cur_dep_package_ids
#
#		# calculate deposit amount = benefit - deposited (self.tot_deposits_made).
#	end
#
#	def update_cur_dep_package_ids
#		# no transaction necessary - can be rerun if problem
#		benes = self.find( :all,
#			:conditions => [ " dep_eff_month = ? and dep_eff_year = ? and deposited_atIS NULL",
#				NameValue.get_val('accounting_month').to_i, NameValue.get_val('accounting_year').to_i ]
#		)
#		for bene in benes
#			if bene.current_package.id != bene.latest_package.id
#				bene.employee_package_id = bene.latest_package.id
#				#todo - should this benefit recalculation be done ?
#				bene.benefit = ( bene.reg_hours + bene.ot_hours ) * bene.latest_package.calc_hourly_benefit
#				# dont update deposit in bulk updates
#				bene.save
#			end
#		end
#	end

#  def current_package
#  	@employee_package = EmployeePackage.find(:first,
#  			:conditions => ["employee_id = ? and deactivated = 0 and (eff_year < ? or (eff_year = ? and eff_month <= ?) )",
#  				self.employee_id,
#					NameValue.get_val('accounting_year').to_i,
#					NameValue.get_val('accounting_year').to_i,
#					NameValue.get_val('accounting_month').to_i
#  			],
#  			:order => 'eff_year DESC, eff_month DESC, id DESC')
#  end

  def current_package
  	@cur_pkg = nil
  	if self.employee_package_id
  		@cur_pkg = EmployeePackage.find(self.employee_package_id)
  	end
  	if @cur_pkg == nil
  		@cur_pkg = self.get_latest_effective_package
  	end
  	if @cur_pkg == nil
  		errors.add(:employee_package_id, "Error - cannot find current benefit package.")
  	end
  	@cur_pkg

  end


	def get_latest_effective_package
		latest_package = EmployeePackage.find(:first,
			:conditions => ["employee_id = ? and ? IS NOT NULL and (eff_year < ? or (eff_year = ? and eff_month <= ?) ) and deactivated = 0 ",
				self.employee_id,
				self.employee_package_id,
				self.eff_year,
				self.eff_year,
				self.eff_month
			],
  			:order => 'eff_year DESC, eff_month DESC, id DESC')

	end
	
  def get_deposits_made
    # is this used?
  	@deposits_made = EmployeeBenefit.find(:all, :conditions => ["employee_id = ? and id <> ? and eff_month = ? and eff_year = ? and deposited_at IS NOT NULL",
  		self.employee_id, self.id, self.eff_month, self.eff_year]
  	)
  end

  def tot_deposits_made
		filter1 = ""
#  	if self != nil && self.id != nil
#  		filter1 = " and id <> " + self.id.to_s
#  	end
  	dep_result = EmployeeBenefit.find_by_sql("select sum(deposit) as tot_deposit" +
  		" from employee_benefits " +
  		" where employee_id = " + self.employee_id.to_s +
  		filter1 +
  		" and eff_month = " + self.eff_month.to_s +
  		" and eff_year = " + self.eff_year.to_s +
  		" and deposited_at IS NOT NULL")
  	if dep_result[0] != nil
  		if dep_result[0].tot_deposit != nil
  			dep_result[0].tot_deposit.to_f
  		else
  			0.00
  		end
  	else
  		0.00
  	end
  end

  def get_pending_deposits
  	@pending_deposits = EmployeeBenefit.find(:all, :conditions => ["employee_id = ? and ? IS NOT NULL and (eff_year < ? or (eff_year = ? and eff_month < ?) ) and deposited_at IS NULL",
  		self.employee_id, self.id, self.eff_year, self.eff_year, self.eff_month]
  	)
  end

  def tot_pending_deposits(dep_at)
#breakpoint
  	dep_pending = EmployeeBenefit.find_by_sql("select sum(deposit) as tot_deposit" +
  		" from employee_benefits " +
  		" where employee_id = " + self.employee_id.to_s +
  		" and ( eff_year < " + self.eff_year.to_s +
  		"  or ( eff_year = " + self.eff_year.to_s +
  		"  and eff_month < " + self.eff_month.to_s + " ) ) " +
  		" and dep_eff_month = " + self.eff_month.to_s +
  		" and dep_eff_year = " + self.eff_year.to_s
#  		" and isnull(deposited_at,'') = '" + dep_at + "'")
#  		" and (" +
#  		"  ( deposited_at IS NULL AND '' = '" + dep_at + "' )" +
#  		"  or (deposited_at =  '" + dep_at + "' )" +
#  		" )"
  	)
  	@tot = 0.00
  	if dep_pending[0] and dep_pending[0].tot_deposit
  		@tot = eval(dep_pending[0].tot_deposit)
  	end
#breakpoint
  	if @tot == nil
  		@tot = 0.00
  	end
  	@tot
  end

  def self.get_deposits
  	@deposits = EmployeeBenefit.find_by_sql("select distinct deposited_at " +
  		" from employee_benefits " +
  		" where dep_eff_month = " + NameValue.get_val("accounting_month") +
  		" and dep_eff_year = " + NameValue.get_val("accounting_year") +
  		" order by deposited_at DESC")
  end

  def self.get_all_deposits
  	@deposits = EmployeeBenefit.find_by_sql("select distinct deposited_at " +
  		" from employee_benefits " +
  		" where dep_eff_year >= " + NameValue.get_val("start_year") +
  		" order by deposited_at DESC")
  end

  def is_current
  	if self.eff_month.to_s == NameValue.get_val("accounting_month") &&
  			self.eff_year.to_s == NameValue.get_val("accounting_year") &&
  			self.dep_eff_month.to_s == NameValue.get_val("accounting_month") &&
  			self.dep_eff_year.to_s == NameValue.get_val("accounting_year") &&
  			self.deposited_at == nil
  		true
  	else
  		false
  	end
  end

  def is_pending
  	if ( self.eff_year < NameValue.get_val("accounting_year").to_i ||
  			( self.eff_year == NameValue.get_val("accounting_year").to_i &&
  				self.eff_month < NameValue.get_val("accounting_month").to_i ) ) &&
  			self.deposited_at == nil
  		true
  	else
  		false
  	end
  end

  def is_pending_selected
  	if ( self.is_pending &&
  			self.dep_eff_month.to_s == NameValue.get_val("accounting_month") &&
  			self.dep_eff_year.to_s == NameValue.get_val("accounting_year") )
  		true
  	else
  		false
  	end
  end

  def is_deposit_out_of_cur_bal
     @latest_pkg = self.get_latest_effective_package
     if @latest_pkg != nil
		@bene_bal = ( @latest_pkg.calc_hourly_benefit.to_f -
			self.tot_current_benefit.to_f -
			self.tot_deposits_made.to_f -
			self.deposit.to_f
		)
		if @bene_bal > 0.005 || @bene_bal < -0.005
			logger.debug("****** deposit_out_of_cur_bal - @bene_bal = "+@bene_bal.to_s)
			true
		else
			false
		end
	else
	   false
	end
  end

  def is_benefit_out_of_cur_bal
     @latest_pkg = self.get_latest_effective_package
		#@cur_pkg = self.current_package
     if @latest_pkg != nil
		#if false && @cur_pkg
			@bene_bal = ( @latest_pkg.calc_hourly_benefit.to_f -
				( self.current_package.calc_hourly_benefit.to_f * self.calc_tot_hours.to_f )
			)

		else
			@bene_bal = 0.0000
		end
		if @bene_bal > 0.0005 || @bene_bal < -0.0005
			logger.debug("****** benefit_out_of_cur_bal - @bene_bal = "+@bene_bal.to_s)
			true
		else
			false
		end
  end


  def is_deposit_out_of_bal
     @cur_pkg = self.current_package
     if @cur_pkg != nil
		@bene_bal = ( self.monthly_benefit.to_f -
			self.tot_current_benefit.to_f -
			self.tot_deposits_made.to_f -
			self.deposit.to_f
		)
		if @bene_bal > 0.005 || @bene_bal < -0.005
			logger.debug("****** deposit_out_of_bal - monthly_benefit = "+self.monthly_benefit.to_f.to_s)
			logger.debug("******                    - tot_current_benefit = "+self.tot_current_benefit.to_f.to_s)
			logger.debug("******                    - tot_deposits_made = "+self.tot_deposits_made.to_f.to_s)
			logger.debug("******                    - deposit = "+self.deposit.to_f.to_s)
			logger.debug("******                    - @bene_bal = "+@bene_bal.to_s)
			true
		else
			false
		end
	else
	   false
	end
  end

  def is_benefit_out_of_bal
     @cur_pkg = self.get_latest_effective_package
		#@cur_pkg = self.current_package
     if @cur_pkg != nil
		#if false && @cur_pkg
			@bene_bal = ( self.monthly_benefit.to_f -
				( self.current_package.calc_hourly_benefit.to_f * self.calc_tot_hours.to_f )
			)

		else
			@bene_bal = 0.0000
		end
		if @bene_bal > 0.0005 || @bene_bal < -0.0005
			logger.debug("****** benefit_out_of_bal - @bene_bal = "+@bene_bal.to_s)
			true
		else
			false
		end
  end




  def is_benefit_changed
  	#@emp = Employee.find(self.employee_id)
  	#@latest_pkg = @emp.emp_latest_pkg
	@latest_pkg = self.get_latest_effective_package
  	if @latest_pkg
	  	if @latest_pkg.id != self.employee_package_id
	  		true
	  	else
			@bene_bal = ( self.hourly_benefit.to_f - @latest_pkg.calc_hourly_benefit.to_f)
			if @bene_bal > 0.0005 || @bene_bal < -0.0005
				true
			else
				false
			end
		end
	else
		    errors.add(:employee_package_id, "Error - getting latest package error ")
		false
	end
  end

  def self.make_cur_deposit
  	cur_time = Time.new
  	cur_time_str = cur_time.strftime("%Y-%m-%d %H:%M:%S")
  	self.transaction do
  		#emp_pkg = EmployeePackage.find(:first, :conditions => ["eff_month = ? and eff_year = ? and deactivated = 0", NameValue.get_accounting_month, NameValue.get_accounting_year] )
  		self.update_all(
  			"deposited_at = '" + cur_time_str + "'",
  			"dep_eff_month = " + NameValue.get_accounting_month +
  				" and dep_eff_year = " + NameValue.get_accounting_year +
  				" and deposited_at IS NULL"
  		)
  	end
  end

  def validate
  	@is_there = Employee.count( :all, :conditions => ["id = ?", self.employee_id])
  	if @is_there < 1
  		errors.add(:employee_id, "Error - invalid employee id.")
  	end
  end

	validates_presence_of :employee_id
	validates_inclusion_of :eff_month, :in => 1..12, :messages => 'invalid effective month'
	validates_inclusion_of :eff_year, :in => 2001...2999, :message => 'invalid effective year'

end
