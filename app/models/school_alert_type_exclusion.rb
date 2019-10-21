# == Schema Information
#
# Table name: school_alert_type_exclusions
#
#  alert_type_id :bigint(8)
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  reason        :text
#  school_id     :bigint(8)
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_school_alert_type_exclusions_on_alert_type_id  (alert_type_id)
#  index_school_alert_type_exclusions_on_school_id      (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class SchoolAlertTypeExclusion < ApplicationRecord
  belongs_to :school
  belongs_to :alert_type
end
