# frozen_string_literal: true

json.charts @output.each do |chart_data_values|
  json.chart_index        1
  json.title              chart_data_values.title
  json.chart1_type        chart_data_values.chart1_type
  json.chart1_subtype     chart_data_values.chart1_subtype
  json.y_axis_label       chart_data_values.y_axis_label
  json.x_axis_label       chart_data_values.x_axis_label
  json.x_axis_categories  chart_data_values.x_axis_categories
  json.advice_header      chart_data_values.advice_header
  json.advice_footer      chart_data_values.advice_footer
  json.y2_axis_label      chart_data_values.y2_axis_label
  json.series_data        chart_data_values.series_data
  json.annotations        chart_data_values.annotations
end
