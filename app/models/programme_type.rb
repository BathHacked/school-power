# == Schema Information
#
# Table name: programme_types
#
#  active            :boolean          default(FALSE)
#  document_link     :string
#  id                :bigint(8)        not null, primary key
#  short_description :text
#  title             :text
#

class ProgrammeType < ApplicationRecord
  has_many :programme_type_activity_types
  has_many :activity_types, through: :programme_type_activity_types

  has_many :programmes

  scope :active, -> { where(active: true) }

  validates_presence_of :title

  accepts_nested_attributes_for :programme_type_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }

  has_rich_text :description

  def update_activity_type_positions!(position_attributes)
    transaction do
      programme_type_activity_types.destroy_all
      update!(programme_type_activity_types_attributes: position_attributes)
    end
  end

  def activity_types_and_school_activity(school)
    programme_type_activity_types.order(:position).map do |programme_type_activity_type|
      activity = school.activities.find_by(activity_type_id: programme_type_activity_type.activity_type_id)
      [programme_type_activity_type.activity_type, activity]
    end
  end
end
