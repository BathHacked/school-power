# == Schema Information
#
# Table name: programme_types
#
#  active      :boolean          default(FALSE)
#  description :text
#  id          :bigint(8)        not null, primary key
#  title       :text
#

class ProgrammeType < ApplicationRecord
  has_many :activity_types

  has_many :alert_type_rating_activity_types
  has_many :activity_types, through: :progamme_type_activity_types

  validates_presence_of :title
end
