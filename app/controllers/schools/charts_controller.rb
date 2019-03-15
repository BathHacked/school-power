require 'dashboard'

class Schools::ChartsController < ApplicationController
  include SchoolAggregation
  include Measurements

  skip_before_action :authenticate_user!
  before_action :set_school

  def show
    @chart_type = params[:chart_type].to_sym

    respond_to do |format|
      format.html do
        set_measurement_options
        @measurement = measurement_unit(params[:measurement])
        @title = @chart_type.to_s.humanize

        # Get this loaded and warm the cache before starting the chart rendering
        aggregate_school(@school)
      end
      format.json do
        chart_config = {
          mpan_mprn: params[:mpan_mprn],
          y_axis_units: params.fetch(:chart_y_axis_units, :kwh).to_sym
        }
        @output = ChartData.new(aggregate_school(@school), @chart_type, show_benchmark_figures?, chart_config).data
      end
    end
  end

private

  def show_benchmark_figures?
    current_user.try(:admin?)
  end

  def set_school
    @school = School.find_by_slug(params[:school_id])
  end
end
