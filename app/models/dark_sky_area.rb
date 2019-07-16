# frozen_string_literal: true

# == Schema Information
#
# Table name: areas
#
#  data_feed_id   :bigint(8)
#  description    :text
#  id             :bigint(8)        not null, primary key
#  latitude       :decimal(10, 6)
#  longitude      :decimal(10, 6)
#  parent_area_id :bigint(8)
#  title          :text
#  type           :text             not null
#
# Indexes
#
#  index_areas_on_data_feed_id    (data_feed_id)
#  index_areas_on_parent_area_id  (parent_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_feed_id => data_feeds.id) ON DELETE => restrict
#

class DarkSkyArea < Area
  has_many :dark_sky_temperature_readings, class_name: 'DataFeeds::DarkSkyTemperatureReading', foreign_key: :area_id
end
