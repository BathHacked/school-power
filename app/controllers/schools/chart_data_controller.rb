require 'dashboard'

class Schools::ChartDataController < ApplicationController
  def show
    chart_manager = ChartManager.new(aggregate_school)
    render json: chart_manager.run_standard_charts
  end

  def excel
    reportmanager = ReportManager.new(aggregate_school)
    worksheets = reportmanager.run_reports(reportmanager.standard_reports)

    excel = ExcelCharts.new(Rails.public_path.join("#{aggregate_school.name}-charts-test.xlsx"))

    worksheets.each do |worksheet_name, charts|
      excel.add_charts(worksheet_name, charts)
    end
    excel.close
    # response.content_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    # send_data excel, filename: "#{aggregate_school.name}-charts-test.xlsx"
  end

  def holidays
    render json: aggregate_school.holidays
  end

  def solar_irradiance
    render json: aggregate_school.solar_insolance
  end

  def solar_pv
    render json: aggregate_school.solar_pv
  end

  def electricity_meters
    render json: aggregate_school.electricity_meters
  end

  def gas_meters
    render json: aggregate_school.heat_meters
  end

  def aggregated_electricity_meters
    render json: aggregate_school.aggregated_electricity_meters.amr_data
  end

  def aggregated_gas_meters
    render json: aggregate_school.aggregated_gas_meters
  end

private

  def aggregate_school
    @school = School.find_by_slug(params[:school_id])
    authorize! :show, @school
    meter_collection = MeterCollection.new(@school)
    AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
  end
end
