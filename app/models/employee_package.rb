class EmployeePackage < ActiveRecord::Base

  before_create :create_timestamp
  before_destroy :validate_on_destroy

  validates_presence_of :employee_id
  validates_inclusion_of :eff_month, :in => 1..12, :message => 'invalid effective month'
  validates_inclusion_of :eff_year, :in => 2001...2999, :message => 'invalid effective year'

  def validate
    super
    @is_there = Employee.count( :all, :conditions => ["id = ?", self.employee_id])
    if @is_there < 1
      errors.add(:employee_id, "Error - invalid employee id.")
    end
  end


  protected	## following methods will be protected

  # Properly set the current date and time in the created_at field on creation
  def create_timestamp
  	self.created_at = Time.now
  end

  def validate_on_destroy
    #coding is placed in destroy method
  	true
  end

# depreciated. use has_deposits.
  def xxx_packages_trail
		emp_pkgs = EmployeeBenefit.count( :all, :conditions => ["employee_package_id = ? and deposited_at IS NOT NULL", self.id] )
#breakpoint
		if emp_pkgs > 0
			# there is an existing benefit for this package, deactivate self before creating new
			errors.add(:employee_id, "Debugging - deposit(s) for package exist 1")
			false
		else
			true
		end
  end


public	## following methods will be public

  def has_deposits
		emp_pkgs = EmployeeBenefit.count( :all, :conditions => ["employee_package_id = ? and deposited_at IS NOT NULL", self.id] )
		if emp_pkgs > 0
			# there is an existing benefit for this package, deactivate self before creating new
			true
		else
			false
		end
  end


  def is_package_duplicate
		emp_pkgs = EmployeePackage.count( :all, :conditions => ["eff_month = ? and eff_year = ? and employee_id = ? and ? IS NOT NULL and deactivated = 0", self.eff_month, self.eff_year, self.employee_id, self.id] )
		if emp_pkgs > 0
			# there is an existing package with the same effective month and year
			# that is a different benefits package record.
			#errors.add(:eff_month, "Error - package exists for effective month already")
			true
		else
			false
		end
  end

  # wrote this, because validate_on_destroy errors did not pass to destroy method
  def destroy
  	@how_many = EmployeePackage.count( :all, :conditions => ["employee_id = ?", self.employee_id])
  	if @how_many < 2
  		errors.add(:employee_id, "Error - cannot delete last package record.")
  		false
  	else
  	@ok_to_save = true
  	@resp = true
  		@has_deposits = EmployeeBenefit.count( :all, :conditions => ["employee_package_id = ?", self.id])
  		if @has_deposits > 0
  			self.deactivated = 1
  			self.save
		  	if !errors.empty?
					errors.add(:deactivated, "Error - deposit(s) for package - could not deactivate")
					@resp = false
				else
					@resp = true
		  	end
  		else
				@resp = super
			end
  	@ok_to_save = false
  	@resp
  	end
  end

  # override of the save method for audited records
  def audit_save *args
  	@is_good = false
  	@ok_to_save = true
    if is_package_duplicate
  		errors.add(:eff_month, "Error - package exists for " + self.eff_month.to_s + "/" + self.eff_year.to_s)
    else
  		@is_good = self.save
    end
  	@ok_to_save = false
  	@is_good
  end

	def save
		if @ok_to_save
			super
		else
			errors.add(:id, "Error - unauthorized save method call.")
			false
		end
	end

  def audit_update_attributes(attributes)
		self.attributes = attributes
		audit_save
  end

  def audit_reactivate()
	self.deactivated = 0
  	@is_good = false
  	@ok_to_save = true
	@is_good = save
  	@ok_to_save = false
  	@is_good
  end


  def set_defaults
		#self.eff_month = NameValue.get_val("accounting_month")
		#self.eff_year = NameValue.get_val("accounting_year")
		self.hourly_wage = 0.00
		self.monthly_medical = 0.00
		self.annual_sick = 0.00
		self.annual_holiday = 0.00
		self.annual_vacation = 0.00
		self.annual_personal = 0.00
		self.safe_harbor_pct = 0.00
  	@employee = Employee.find(self.employee_id)
  	if @employee != nil
  		@emp_latest_pkg = @employee.emp_latest_pkg
  		if @emp_latest_pkg != nil
  			self.hourly_wage = @emp_latest_pkg.hourly_wage
  			self.monthly_medical = @emp_latest_pkg.monthly_medical
  			self.annual_sick = @emp_latest_pkg.annual_sick
  			self.annual_holiday = @emp_latest_pkg.annual_holiday
  			self.annual_vacation = @emp_latest_pkg.annual_vacation
  			self.annual_personal = @emp_latest_pkg.annual_personal
  			self.safe_harbor_pct = @emp_latest_pkg.safe_harbor_pct
  			#errors.add(:employee_id, "Debugging - copied package values from " + @emp_latest_pkg.id.to_s)
  		else
  			#errors.add(:employee_id, "Debugging - no package to copy from ")
	  	end
  	else
  		errors.add(:employee_id, "Error - cannot find employee for id " + self.employee_id)
  	end
  end

  def old_initialize *args
  	if self.eff_month == nil
  		self.eff_month = NameValue.get_val("accounting_month")
  	end
  	if self.eff_year == nil
  		self.eff_year = NameValue.get_val("accounting_year")
  	end
  	if self.hourly_wage == nil
  		self.hourly_wage = 0.00
  	end
  	if self.monthly_medical == nil
  		self.monthly_medical = 0.00
  	end
  	if self.annual_sick == nil
  		self.annual_sick = 0.00
  	end
  	if self.annual_holiday == nil
  		self.annual_holiday = 0.00
  	end
  	if self.annual_vacation == nil
  		self.annual_vacation = 0.00
  	end
  	if self.annual_personal == nil
  		self.annual_personal = 0.00
  	end
  	if self.safe_harbor_pct == nil
  		self.safe_harbor_pct = 0.00
  	end
  	@employee = Employee.find(self.employee_id)
  	if @employee != nil
  		@emp_latest_pkg = @employee.emp_latest_pkg
  		if @emp_latest_pkg != nil
  			self.hourly_wage = @emp_latest_pkg.hourly_wage
  			self.monthly_medical = @emp_latest_pkg.monthly_medical
  			self.annual_sick = @emp_latest_pkg.annual_sick
  			self.annual_holiday = @emp_latest_pkg.annual_holiday
  			self.annual_vacation = @emp_latest_pkg.annual_vacation
  			self.annual_personal = @emp_latest_pkg.annual_personal
  			self.safe_harbor_pct = @emp_latest_pkg.safe_harbor_pct
  			#errors.add(:employee_id, "Debugging - copied package values from " + @emp_latest_pkg.id.to_s)
  		else
  			#errors.add(:employee_id, "Debugging - no package to copy from ")
	  	end
  	else
  		errors.add(:employee_id, "Error - cannot find employee for id " + self.employee_id)
  	end
  	@ok_to_save = false
  	self
  end

  def calc_hourly_shvp
  	(
  		if self.annual_sick == nil
  			self.annual_sick = 0.0
  			logger.debug("annual_sick==nil")
  		end
  		if self.annual_holiday == nil
  			self.annual_holiday = 0.0
  			logger.debug("annual_holiday==nil")
  		end
  		if self.annual_vacation == nil
  			self.annual_vacation = 0.0
  			logger.debug("annual_vacation==nil")
  		end
  		if self.annual_personal == nil
  			self.annual_personal = 0.0
  			logger.debug("annual_personal==nil")
  		end
  		if self.hourly_wage == nil
  			self.hourly_wage = 0.0
  			logger.debug("hourly_wage==nil")
  		end
  		self.annual_sick + self.annual_holiday + self.annual_vacation + self.annual_personal
  	) * self.hourly_wage / 2080.0	#todo pull this from name_values once caching is set up
  end

  def calc_sh_pct_amt
  	(
  		if self.safe_harbor_pct == nil
  			self.safe_harbor_pct = 0.0
  			logger.debug("safe_harbor_pct==nil")
  		else
  	    #logger.debug("safe_harbor_pct = "+sprintf("%5.2f",self.safe_harbor_pct))
  	  end
  		if self.hourly_wage == nil
  			self.hourly_wage = 0.0
  			logger.debug("hourly_wage==nil")
  		else
  	    #logger.debug("hourly_wage = "+sprintf("%5.2f",self.hourly_wage))
  		end
  		self.safe_harbor_pct
  	) * self.hourly_wage / 100.0	#todo pull this from name_values once caching is set up
  end

  def calc_hourly_medical
  	(
  		if self.monthly_medical == nil
  			self.monthly_medical = 0.0
  			logger.debug("monthly_medical==nil")
  		end
  		(self.monthly_medical * 12.0)
		) / 2080.0	#todo pull this from name_values once caching is set up
  end

  def calc_hourly_benefit
  	self.calc_hourly_shvp + self.calc_sh_pct_amt + self.calc_hourly_medical
  end

# allow duplicates, because old ones will be deactivated
#  def validate_on_create
#  	@is_dup = EmployeePackage.count( :all, :conditions => ["employee_id = ? and eff_month = ? and eff_year = ?",
#  			self.employee_id, self.eff_month, self.eff_year])
#  	if @is_dup > 0
#  		errors.add_to_base("Error - duplicate effective month and year for employee.")
#  	end
#  end

# check to see if any deposits for this package
  def has_deposits
  	@has_deps = EmployeeBenefit.count( :all, :conditions => ["employee_package_id = ? and deposited_at IS NOT NULL",
  			self.id])
  	if @has_deps > 0
  		true
  	else
  		false
  	end
  end

end
