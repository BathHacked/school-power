# frozen_string_literal: true

# == Schema Information
#
# Table name: key_stages
#
#  id   :bigint(8)        not null, primary key
#  name :string
#
# Indexes
#
#  index_key_stages_on_name  (name) UNIQUE
#

class KeyStage < ApplicationRecord
end
