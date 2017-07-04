class StatsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  skip_before_action :authenticate_user!

  # GET /schools/:id/daily_usage?supply=:supply&to_date=:to_date&meter=:meter_no
  def daily_usage
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    this_week = school.daily_usage(
      supply: supply,
      dates: to_date - 6.days..to_date,
      date_format: '%A',
      meter: meter
    ).map(&precision)
    previous_week = school.daily_usage(
      supply: supply,
      dates: to_date - 13.days..to_date - 7.days,
      meter: meter
    ).map(&precision)
    previous_week_series = previous_week.map.with_index do |day, index|
      # this week's dates with previous week's usage
      [this_week[index][0], day[1]]
    end
    render json: [
      { name: 'Latest 7 days', data: this_week },
      { name: 'Previous 7 days', data: previous_week_series }
    ]
  end

  #compare hourly usage across two dates
  # GET /schools/:id/compare_hourly_usage?supply=:supply&meter=:meter_no&first_date=:first_date&to_date=:second_date
  def compare_hourly_usage
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    from = Date.parse(params[:first_date])
    to = Date.parse(params[:to_date])
    first_date = school.hourly_usage_for_date(supply: supply,
        date: from,
        meter: meter,
        scale: :kw
    ).map(&precision)
    to_date = school.hourly_usage_for_date(supply: supply,
        date: to,
        meter: meter,
        scale: :kw
    ).map(&precision)
    render json: [
        { name: to.strftime('%A, %d %B %Y'), data: to_date },
        { name: from.strftime('%A, %d %B %Y'), data: first_date }

    ]
  end

  # GET /schools/:id/hourly_usage?supply=:supply&to_date=:to_date&meter=:meter_no
  # compares hourly usage by weekday/weekend for last full week
  def hourly_usage
    week = Usage.this_week(to_date).to_a
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    weekend = school.hourly_usage(
      supply: supply,
      dates: week[0]..week[1],
      meter: meter
    ).map(&precision)
    weekday = school.hourly_usage(
      supply: supply,
      dates: week[2]..week[6],
      meter: meter
    ).map(&precision)
    render json: [
      { name: 'Weekday', data: weekday },
      { name: 'Weekend', data: weekend }
    ]
  end

private


  # Use callbacks to share common setup or constraints between actions.
  def school
    School.find(params[:id])
  end

  def meter
    params[:meter]
  end

  def supply
    params[:supply]
  end

  def to_date
    Date.parse(params[:to_date])
  rescue
    Date.current
  end
end
