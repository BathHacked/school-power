require 'rails_helper'

module Meters
  describe UserTariffMeterAttributes do

    let(:school) { create(:school) }
    let(:service) { UserTariffMeterAttributes.new(user_tariff) }

    context 'with differential electricity tariff' do

      let(:user_tariff_price)  { UserTariffPrice.new(start_time: '00:00', end_time: '23:30', value: 1.23, units: 'kwh') }
      let(:user_tariff_charge_1)  { UserTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }
      let(:user_tariff_charge_2)  { UserTariffCharge.new(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }

      let(:user_tariff)  do
        UserTariff.new(
          school: school,
          start_date: '2021-04-01',
          end_date: '2022-03-31',
          name: 'My First Tariff',
          flat_rate: false,
          user_tariff_prices: [user_tariff_price],
          user_tariff_charges: [user_tariff_charge_1, user_tariff_charge_2],
        )
      end

      let(:example) do
        {
          "start_date": "01/04/2021",
          "end_date": "31/03/2022",
          "source": "manually_entered",
          "name": "My First Tariff",
          "type": "differential",
          "sub_type": "",
          "vat": "5%",
          "rates": {
            "rate0": {
              "per": "kwh",
              "rate": "1.23",
              "from": {
                "hour": "0",
                "minutes": "0"
              },
              "to": {
                "hour": "23",
                "minutes": "30"
              }
            },
            "duos_red": "1111",
            "duos_amber": "2222",
            "duos_green": "3333",
            "weekday": "1",
            "weekend": "1",
            "standing_charge": {
              "per": "month",
              "rate": "4.56"
            },
            "climate_change_levy": {
              "per": "kwh",
              "rate": "999"
            },
            "renewable_energy_obligation": {
              "per": "kwh",
              "rate": "888"
            },
            "feed_in_tariff_levy": {
              "per": "kwh",
              "rate": "777"
            },
            "agreed_capacity": {
              "per": "month",
              "rate": "666"
            },
            "agreed_availability_charge": {
              "per": "kva",
              "rate": "555"
            },
            "settlement_agency_fee": {
              "per": "day",
              "rate": "444"
            },
            "reactive_power_charge": {
              "per": "kva",
              "rate": "333"
            },
            "half_hourly_data_charge": {
              "per": "day",
              "rate": "222"
            },
            "fixed_charge": {
              "per": "month",
              "rate": "987"
            },
            "nhh_metering_agent_charge": {
              "per": "kwh",
              "rate": "765"
            },
            "meter_asset_provider_charge": {
              "per": "month",
              "rate": "654"
            },
            "site_fee": {
              "per": "month",
              "rate": "432"
            },
            "other": {
              "per": "quarter",
              "rate": "223344"
            }
          },
          "asc_limit_kw": "123123",
          "climate_change_levy": "1"
        }
      end

      it "should include basic fields" do
        attributes = service.to_meter_attributes

        expect(attributes['name']).to eq('My First Tariff')
        expect(attributes['start_date']).to eq('01/04/2021')
        expect(attributes['end_date']).to eq('31/03/2022')
        expect(attributes['source']).to eq('manually_entered')
        expect(attributes['type']).to eq('differential')
        expect(attributes['sub_type']).to eq('')
        expect(attributes['vat']).to eq('5%')
      end

      it "should include standing charges" do
        attributes = service.to_meter_attributes

        expect(attributes['rates']['fixed_charge']).to eq({'per' => 'month', 'rate' => '4.56'})
        expect(attributes['rates']['agreed_availability_charge']).to eq({'per' => 'kva', 'rate' => '6.78'})
      end
    end

  end
end