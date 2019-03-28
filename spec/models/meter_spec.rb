require 'rails_helper'

class DummyMeterAttributes

  ATTRIBUTES = {
      meter_corrections: [{ readings_start_date: Date.new(2010, 6, 25), }],
      storage_heaters: [{ start_date: Date.new(2010, 1, 1) }],
      solar_pv: [ 'yay']
    }

  def self.for(mpan_mprn = nil, area_name = nil, meter_type = nil)
    ATTRIBUTES
  end
end

describe 'Meter', :meters do
  describe 'meter attributes' do
    let(:meter) { build(:electricity_meter) }

    it 'can get them all' do
      meter =  build(:electricity_meter)
      expect(meter.meter_attributes(DummyMeterAttributes)).to eq DummyMeterAttributes::ATTRIBUTES
    end

    it 'drops storage heaters if env set' do
      allow(ENV).to receive(:[]).with("DISABLE_SOLAR_PV_AND_STORAGE_HEATERS").and_return('aye')
      attributes_without_storage = DummyMeterAttributes::ATTRIBUTES.except(:storage_heaters).except(:solar_pv)
      expect(meter.meter_attributes(DummyMeterAttributes)).to eq attributes_without_storage
    end
  end

  describe 'valid?' do
    describe 'mpan_mprn' do
      context 'with an electricity meter' do

        let(:attributes) {attributes_for(:electricity_meter)}

        it 'is valid with a 13 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'validates the distributor id' do
          meter = Meter.new(attributes.merge(mpan_mprn: 9998598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end
      end

      context 'with a gas meter' do
        let(:attributes) {attributes_for(:gas_meter)}

        it 'is valid with a 10 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number longer than 10 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 8758348459567832))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end
    end
  end

  describe 'correct_mpan_check_digit?' do
    it 'returns true if the check digit matches' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns false if the check digit does not match' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end

    it 'returns false if the mpan is short' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end
  end

  describe '#last_validated_reading' do
    it "should find latest reading" do
      reading = create(:amr_validated_reading, reading_date: Date.parse('2018-12-01'))
      meter = reading.meter

      expect(meter.last_validated_reading).to eql(reading.reading_date)

      today = create(:amr_validated_reading, meter: meter, reading_date: Date.parse('2018-12-03'))
      create(:amr_validated_reading, meter: meter, reading_date: Date.parse('2018-12-02'))

      expect(meter.last_validated_reading).to eql(today.reading_date)
    end
  end

  describe '#first_validated_reading' do
    it "should find first reading" do
      reading = create(:amr_validated_reading, reading_date: Date.parse('2018-12-02'))
      meter = reading.meter

      expect(meter.first_validated_reading).to eql(reading.reading_date)

      today = create(:amr_validated_reading, meter: meter, reading_date: Date.parse('2018-12-03'))
      old_one = create(:amr_validated_reading, meter: meter, reading_date: Date.parse('2018-12-01'))

      expect(meter.first_validated_reading).to eql(old_one.reading_date)
    end
  end

  describe '#safe_destroy' do

    it 'does not let you delete if there is an assoicated meter reading' do
      meter = create(:electricity_meter)
      create(:amr_data_feed_reading, meter: meter)

      expect{
        meter.safe_destroy
      }.to raise_error(EnergySparks::SafeDestroyError, 'Meter has associated readings')
    end

    it 'does not let you delete if there is an assoicated AMR meter reading' do
      meter = create(:electricity_meter)
      # TODO: find a better way of generating this record?
      meter.amr_data_feed_readings.create!(
        mpan_mprn: meter.mpan_mprn,
        reading_date: Date.today,
        readings: ["1.0"] * 48
      )

      expect{
        meter.safe_destroy
      }.to raise_error(EnergySparks::SafeDestroyError, 'Meter has associated readings')
    end

    it 'lets you delete if there are no meter readings' do
      meter = create(:electricity_meter)

      expect{
        meter.safe_destroy
      }.to change{Meter.count}.from(1).to(0)
    end

  end
end
