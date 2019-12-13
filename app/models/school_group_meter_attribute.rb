# == Schema Information
#
# Table name: school_group_meter_attributes
#
#  attribute_type  :string           not null
#  created_at      :datetime         not null
#  created_by_id   :bigint(8)
#  deleted_by_id   :bigint(8)
#  id              :bigint(8)        not null, primary key
#  input_data      :json
#  meter_type      :string           not null
#  reason          :text
#  replaced_by_id  :bigint(8)
#  school_group_id :bigint(8)        not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_school_group_meter_attributes_on_school_group_id  (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (deleted_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (replaced_by_id => school_group_meter_attributes.id) ON DELETE => nullify
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => cascade
#

class SchoolGroupMeterAttribute < ApplicationRecord
  belongs_to :school_group

  belongs_to :replaced_by, class_name: 'SchoolGroupMeterAttribute', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  has_one :replaces, class_name: 'SchoolGroupMeterAttribute', foreign_key: :replaced_by_id

  scope :active,  -> { where(replaced_by_id: nil, deleted_by_id: nil) }
  scope :deleted, -> { where(replaced_by_id: nil).where.not(deleted_by_id: nil) }

  def to_analytics
    meter_attribute_type.parse(input_data).to_analytics
  end

  def pseudo?
    meter_attribute_type.applicable_attribute_pseudo_meter_types.include?(meter_type.to_sym)
  end

  def meter_attribute_type
    MeterAttributes.all[attribute_type.to_sym]
  end
end