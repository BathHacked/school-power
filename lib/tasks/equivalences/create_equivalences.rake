# frozen_string_literal: true

namespace :equivalences do
  desc 'Run equivalences job'
  task create: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running all equivalences for #{school.name}"
      Equivalences::GenerateEquivalences.new(school, EnergyConversions).perform
    end
    puts Time.zone.now
  end
end
