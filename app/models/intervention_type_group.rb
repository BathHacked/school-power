# == Schema Information
#
# Table name: intervention_type_groups
#
#  created_at :datetime         not null
#  icon       :string           default("question-circle")
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  updated_at :datetime         not null
#

class InterventionTypeGroup < ApplicationRecord
  has_many :intervention_types

  validates :title, presence: true, uniqueness: true
end
