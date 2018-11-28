FactoryBot.define do
  factory :amr_data_feed_reading do
    reading_date Date.yesterday
    readings { Array.new(48, rand) }
    association :meter, factory: :gas_meter
    mpan_mprn { Random.new.rand(240000000000000)}
  end
end
