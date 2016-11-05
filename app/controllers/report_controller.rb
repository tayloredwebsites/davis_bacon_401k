class ReportController < ApplicationController

  # ensure user logged in before using, except in test mode
  if ENV['RAILS_ENV'] != 'test'
    before_filter :login_required
  end

  layout  'report'

  def employee_master_report
    @show_deactivated = params[:show_deactivated].to_s
    if @show_deactivated == nil || @show_deactivated == ''
      @show_deactivated = '0'
    end
    @employees = Employee.where("deactivated = ?", @show_deactivated).order('emp_id')
  end

  def entry_recon_options

    @has_args = true

    get_start_end_months

    @show_deactivated = params[:show_deactivated].to_s
    if @show_deactivated == nil || @show_deactivated == ''
      @show_deactivated = '0'
    end

  end

  def entry_recon_report

    @has_args = true

    get_start_end_months

    @show_deactivated = params[:show_deactivated].to_s
    if @show_deactivated == nil || @show_deactivated == ''
      @show_deactivated = '0'
    end

    @employee_benefits = nil
    if @has_args
      @employee_benefits = EmployeeBenefit.find_by_sql [
        "select * from employee_benefits b " +
        " inner join employees e on b.employee_id = e.id " +
        " where ( eff_year > ? or ( eff_year = ?  and eff_month >= ? ) ) " +
        " and ( eff_year < ? or ( eff_year = ?  and eff_month <= ? ) ) ",
        @select_start_year, @select_start_year, @select_start_month,
        @select_end_year, @select_end_year, @select_end_month
      ]
    else
        flash[:notice] = 'Error - Missing starting and ending months.'
        redirect_to :action => 'entry_recon_options'
    end
  end

  def deposit_recon_options

    @has_args = true

    @all_deposits = EmployeeBenefit.get_all_deposits

    @detail_report = params[:detail_report].to_s
    if @detail_report == nil || @detail_report == ''
      @detail_report = '0'
    end

  end

  def deposit_recon_report

    if params[:select_start_deposit] < params[:select_end_deposit]
        @select_start_deposit = params[:select_start_deposit]
        @select_end_deposit = params[:select_end_deposit]
      else
        @select_start_deposit = params[:select_end_deposit]
        @select_end_deposit = params[:select_start_deposit]
      end

    @has_args = false
    if @select_start_deposit && @select_start_deposit != '' && @select_end_deposit && @select_end_deposit != ''
      @has_args = true
    end

    @detail_report = params[:detail_report].to_s
    if @detail_report == nil || @detail_report == ''
      @detail_report = '0'
    end

    @employee_benefits = nil
    if @has_args
      @sql =  "select null as emp_id, null as last_name, null as first_name, " +
        " null as mi, null as eff_month, null as eff_year, " +
        " null as dep_eff_month, null as dep_eff_year, " +
        " null as reg_hours, null as ot_hours, " +
        " null as hourly_benefit, null as monthly_benefit, " +
        " sum(b.deposit) as deposit, deposited_at, 1 as total_row " +
        " from employee_benefits b " +
        " inner join employees e on b.employee_id = e.id " +
        " where b.deposited_at >= ? and b.deposited_at <= ? " +
        # " group by b.deposited_at, e.emp_id with rollup " +
        # " group by b.deposited_at with rollup "
        " group by b.deposited_at "
      if @detail_report != 0
        @sql += " union select e2.emp_id, e2.last_name, e2.first_name, mi, b2.eff_month, b2.eff_year, b2.dep_eff_month, " +
          " b2.dep_eff_year, b2.reg_hours, b2.ot_hours, b2.hourly_benefit, b2.monthly_benefit, " +
          " b2.deposit, b2.deposited_at, 0 as total_row " +
          " from employee_benefits b2 " +
          " inner join employees e2 on b2.employee_id = e2.id " +
          " where b2.deposited_at >= ? and b2.deposited_at <= ? " +
          " order by deposited_at, total_row, emp_id, eff_year, eff_month "
        @employee_benefits = EmployeeBenefit.find_by_sql [ @sql,
          @select_start_deposit, @select_end_deposit, @select_start_deposit, @select_end_deposit
        ]
      else
        @employee_benefits = EmployeeBenefit.find_by_sql [ @sql + " order by deposited_at, emp_id ",
          @select_start_deposit, @select_end_deposit
        ]
      end

    else
        flash[:notice] = 'Error - Missing starting and ending deposits.'
        redirect_to :action => 'deposit_recon_options'
    end
  end


  def monthly_benefits_options

    @has_args = true

    get_start_end_months

    @show_deactivated = params[:show_deactivated].to_s
    if @show_deactivated == nil || @show_deactivated == ''
      @show_deactivated = '0'
    end

    @detail_report = params[:detail_report].to_s
    if @detail_report == nil || @detail_report == ''
      @detail_report = '0'
    end

  end

  def monthly_benefits_report

    @has_args = true

    get_start_end_months

    @show_deactivated = params[:show_deactivated].to_s
    if @show_deactivated == nil || @show_deactivated == ''
      @show_deactivated = '0'
    end

    @detail_report = params[:detail_report].to_s
    if @detail_report == nil || @detail_report == ''
      @detail_report = '0'
    end

    @employee_benefits = nil
    if @has_args
      @sql = "select emp_id, null as last_name, null as first_name, " +
        #" null as mi, eff_month, eff_year, " +
        " null as mi, null as eff_month, null as eff_year, " +
        " null as dep_eff_month, null as dep_eff_year, " +
        " null as reg_hours, null as ot_hours, " +
        " null as hourly_benefit, null as monthly_benefit, " +
        " sum(b.deposit) as deposit,  null as deposited_at, 1 as total_row " +
        " from employee_benefits b " +
        " inner join employees e on b.employee_id = e.id " +
        " where ( eff_year > ? or ( eff_year = ?  and eff_month >= ? ) ) " +
        " and ( eff_year < ? or ( eff_year = ?  and eff_month <= ? ) ) " +
        #" group by b.eff_year, b.eff_month, e.emp_id with rollup "
        #" group by e.emp_id with rollup "
        " group by e.emp_id "
      if @detail_report != 0
        @sql += " union select e2.emp_id, e2.last_name, e2.first_name, e2.mi, b2.eff_month, b2.eff_year, b2.dep_eff_month, " +
        " b2.dep_eff_year, b2.reg_hours, b2.ot_hours, b2.hourly_benefit, b2.monthly_benefit, " +
        " b2.deposit, b2.deposited_at, 0 as total_row " +
        " from employee_benefits b2 " +
        " inner join employees e2 on b2.employee_id = e2.id " +
        " where ( eff_year > ? or ( eff_year = ?  and eff_month >= ? ) ) " +
        " and ( eff_year < ? or ( eff_year = ?  and eff_month <= ? ) ) " +
        #" order by eff_year, eff_month, emp_id "
        " order by emp_id, total_row, eff_year, eff_month, deposited_at "
        @employee_benefits = EmployeeBenefit.find_by_sql [ @sql,
          @select_start_year, @select_start_year, @select_start_month,
          @select_end_year, @select_end_year, @select_end_month,
          @select_start_year, @select_start_year, @select_start_month,
          @select_end_year, @select_end_year, @select_end_month
        ]
      else
        @employee_benefits = EmployeeBenefit.find_by_sql [ @sql,
          @select_start_year, @select_start_year, @select_start_month,
          @select_end_year, @select_end_year, @select_end_month
        ]
      end

    else
        flash[:notice] = 'Error - Missing starting and ending deposits.'
        redirect_to :action => 'monthly_benefits_options'
    end
  end



  def get_start_end_months

    @time_now = Time.now
    @time_now.year

    @has_args = true

    @select_start_year = params[:select_start_year].to_s
    if @select_start_year == nil || @select_start_year == ''
      @select_start_year = @time_now.year.to_s
      @has_args = false
    end

    @select_start_month = params[:select_start_month].to_s
    if @select_start_month == nil || @select_start_month == ''
      @select_start_month = @time_now.month.to_s
      @has_args = false
    end

    @select_end_year = params[:select_end_year].to_s
    if @select_end_year == nil || @select_end_year == ''
      @select_end_year = @time_now.year.to_s
      @has_args = false
    end

    @select_end_month = params[:select_end_month].to_s
    if @select_end_month == nil || @select_end_month == ''
      @select_end_month = @time_now.month.to_s
      @has_args = false
    end

  end

end
