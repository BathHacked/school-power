class Teachers::SchoolsController < SchoolsController
  include ActivityTypeFilterable

  # GET /schools/freshford
  def show
    redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))
    @activities_count = @school.activities.count
    @latest_alerts_sample = @school.alerts.usable.latest.sample

    @charts = [:teachers_landing_page_electricity, :teachers_landing_page_gas]
    @number_of_charts = @charts.size

    @first = @school.activities.empty?
    @suggestions = NextActivitySuggesterWithFilter.new(@school, activity_type_filter).suggest
  end
end
