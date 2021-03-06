# == Schema Information
#
# Table name: intervention_types
#
#  id                         :bigint(8)        not null, primary key
#  intervention_type_group_id :bigint(8)        not null
#  other                      :boolean          default(FALSE)
#  points                     :integer
#  title                      :string           not null
#
# Indexes
#
#  index_intervention_types_on_intervention_type_group_id  (intervention_type_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (intervention_type_group_id => intervention_type_groups.id) ON DELETE => cascade
#

class InterventionType < ApplicationRecord
  belongs_to :intervention_type_group
  has_many :observations

  validates :intervention_type_group, :title, presence: true
  validates :title, uniqueness: { scope: :intervention_type_group_id }

  scope :display_order, -> { order(:other, :title) }

  def display_with_points
    points ? "#{title} (#{points} points)" : title
  end
end
