class Employee < ActiveRecord::Base

	has_many :emp_pkgs,
		:class_name => 'EmployeePackage',
		:order => "eff_year DESC, eff_month DESC, id DESC",
		:conditions => ["eff_year >= ?", NameValue.get_val('start_year').to_i]
		#:conditions => ["deactivated = 0 AND eff_year >= ?", NameValue.get_val('start_year').to_i]

	#has_one :emp_latest_pkg,
	#	:class_name => 'EmployeePackage',
	#	:conditions => ["employee_id = ?", self.id],
	#	:order => 'eff_year DESC, eff_month DESC, id DESC'

	#has_one :cur_benefit,
	#	:class_name => 'EmployeeBenefit',
	#	# put null deposited date as first entry, then by date descending order
	#	:order => "CAST (ISNULL(deposited_at, CAST('12/31/2999' AS DATETIME) ) AS VARCHAR(15) ) DESC",
	#	:conditions => ["eff_month = ? and eff_year = ?",
	#		NameValue.get_val('accounting_month').to_i,
	#		NameValue.get_val('accounting_year').to_i
	#	]


  protected	## following methods will be protected

  before_create :create_timestamp

  # Properly set the current date and time in the created_at field on creation
  def create_timestamp
  	self.created_at = Time.now
  end

  before_destroy :validate_on_destroy

  # make sure record is deactivated before destroying
  def validate_on_destroy
  	if self.deactivated == 0
			errors.add(:deactivated, "cannot destroy active record")
			false
		else
			# code to prevent records deposited
	    @num_benefits = EmployeeBenefit.count( :all, :conditions => ["employee_id = ?", self.id])
	    if @num_benefits > 0
				errors.add(:id, "Error - cannot delete, employee has benefits recorded")
				false
			else
				true
			end
  	end
  end

public	## following methods will be public

  # wrote this, because validate_on_destroy errors did not pass to destroy method
  def destroy
  	if self.deactivated == 0
			errors.add(:deactivated, "cannot destroy active record 2")
			false
			#raise "Error - cannot destroy active record"
		else
			# code to prevent records deposited
	    @num_benefits = EmployeeBenefit.count( :all, :conditions => ["employee_id = ?", self.id])
	    if @num_benefits > 0
				errors.add(:id, "Error - cannot delete, employee has benefits recorded 2")
				false
			else
				super
			end
  	end
  	if errors.empty?
			super
  	end
  end

  # method to deactivate record
  def deactivate
  	if self.deactivated == 0
			self.deactivated = 1
  	else
			errors.add(:deactivated, "record already deactivated")
  	end
  end

  def reactivate
  	if self.deactivated == 1
			self.deactivated = 0
  	else
			errors.add(:deactivated, "record already reactivated")
  	end
  end

  def emp_latest_pkg
  	@employee_package = EmployeePackage.find(:first,
  			:conditions => ["employee_id = ? and (eff_year < ? or (eff_year = ? and eff_month <= ?) ) and deactivated = 0 ",
  				self.id,
					NameValue.get_val('accounting_year').to_i,
					NameValue.get_val('accounting_year').to_i,
					NameValue.get_val('accounting_month').to_i
				],
  			:order => 'eff_year DESC, eff_month DESC, id DESC')
  end

  def cur_benefit
  	work_benefit = self.undeposited_benefit
  	if work_benefit == nil
  		work_benefit = self.latest_deposited_benefit
  	end
  	work_benefit
  end

  def undeposited_benefit
  	@employee_benfit = EmployeeBenefit.find(:first,
			:conditions => ["employee_id = ? and eff_month = ? and eff_year = ? and deposited_at IS NULL",
				self.id,
				NameValue.get_val('accounting_month').to_i,
				NameValue.get_val('accounting_year').to_i
			],
			:order => 'id DESC'
		)
	end

	def latest_benefit
		@employee_benfit = EmployeeBenefit.find(:first,
			:conditions => ["employee_id = ? and eff_month = ? and eff_year = ?",
				self.id,
				NameValue.get_val('accounting_month').to_i,
				NameValue.get_val('accounting_year').to_i
			],
			:order => 'deposited_at DESC, id DESC'
		)
  end

	def latest_deposited_benefit
		@employee_benfit = EmployeeBenefit.find(:first,
			:conditions => ["employee_id = ? and deposited_at IS NOT NULL and eff_month = ? and eff_year = ?",
				self.id,
				NameValue.get_val('accounting_month').to_i,
				NameValue.get_val('accounting_year').to_i
			],
			:order => 'deposited_at DESC, id DESC'
		)
  end

	def latest_current_benefit
		@employee_benfit = EmployeeBenefit.find(:first,
			:conditions => ["employee_id = ? and deposited_at IS NULL and eff_month = ? and eff_year = ?",
				self.id,
				NameValue.get_val('accounting_month').to_i,
				NameValue.get_val('accounting_year').to_i
			],
			:order => 'deposited_at DESC, id DESC'
		)
  end

  validates_uniqueness_of :id, :on => :save
  validates_uniqueness_of :emp_id, :on => :save
  validates_uniqueness_of :ssn, :on => :save
  validates_presence_of :emp_id
  validates_length_of :last_name, :within => 1..40
  validates_length_of :first_name, :within => 1..40
  validates_length_of :mi, :within => 0..1
  validates_length_of :ssn, :is => 9

end
