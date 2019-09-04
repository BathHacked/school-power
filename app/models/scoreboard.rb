# == Schema Information
#
# Table name: scoreboards
#
#  calendar_area_id :bigint(8)
#  created_at       :datetime         not null
#  description      :string
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_scoreboards_on_calendar_area_id  (calendar_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_area_id => calendar_areas.id) ON DELETE => restrict
#

class Scoreboard < ApplicationRecord
  extend FriendlyId

  FIRST_YEAR = 2018

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :school_groups
  has_many :schools, through: :school_groups
  belongs_to :calendar_area

  validates :name, :calendar_area_id, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Scoreboard has associated groups' if school_groups.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def active_academic_years(today: Time.zone.today)
    calendar_area.academic_years.where("date_part('year', start_date) >= ? AND start_date <= ?", FIRST_YEAR, today).order(:start_date)
  end

  def scored_schools(recent_boundary: 1.month.ago, academic_year: this_academic_year)
    scored = schools.active.select('schools.*, SUM(observations.points) AS sum_points, MAX(observations.at) AS recent_observation').select(
      self.class.sanitize_sql_array(
        ['SUM(observations.points) FILTER (WHERE observations.at > ?) AS recent_points', recent_boundary]
      )
    ).
      order(Arel.sql('sum_points DESC NULLS LAST, MAX(observations.at) DESC, schools.name ASC')).
      group('schools.id')
    if academic_year
      scored.joins(
        self.class.sanitize_sql_array(
          ['INNER JOIN observations ON observations.school_id = schools.id AND observations.at BETWEEN ? AND ?', academic_year.start_date, academic_year.end_date]
        )
      )
    else
      scored.left_outer_joins(:observations)
    end
  end

  def position(school)
    scored_schools.index(school)
  end

  private

  def this_academic_year
    calendar_area.academic_year_for(Time.zone.today)
  end
end
