require 'rails_helper'

RSpec.describe 'Dark sky areas', type: :system do
  let!(:admin)                  { create(:admin) }
  let(:title)                   { 'Lights out for darker skies' }
  let(:description)             { 'Better for badgers' }
  let(:latitude)                { 123.456 }
  let(:longitude)               { -789.012 }

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Dark Sky Areas'
    end

    xit 'can create a new dark sky area' do
      expect(page).to have_content("There are no Dark Sky Areas.")

      click_on 'New'

      fill_in 'Title', with: title
      fill_in 'Description', with: description
      fill_in 'Latitude', with: latitude
      fill_in 'longitude', with: longitude

      expect { click_on 'Create' }.to change { DarkSkyArea.count }.by(1)

      expect(page).to have_content("New Dark Sky Area created")
      expect(page).to have_content('Dark Sky Areas')
      expect(page).to have_content title
      expect(page).to have_content description
      expect(page).to have_content latitude
      expect(page).to have_content longitude
    end

    context 'with an existing dark sky area' do

      let!(:area) { DarkSkyArea.create(title: title, description: description, latitude: latitude, longitude: longitude) }

      before(:each) do
        expect(page).to have_content('Dark Sky Areas')
        expect(page).to have_content title
        expect(page).to have_content description
        expect(page).to have_content latitude
        expect(page).to have_content longitude
      end

      xit 'can be edited' do
        click_on 'Edit'

        new_latitude = 111.111
        new_longitude = 999.999
        fill_in 'Latitude', with: new_latitude
        fill_in 'Longitude', with: new_longitude

        click_on 'Update'

        expect(page).to have_content("Dark Sky Area updated")

        expect(page).to have_content('Dark Sky Areas')
        expect(page).to have_content title
        expect(page).to have_content description
        expect(page).to have_content new_latitude
        expect(page).to have_content new_longitude
      end

      xit 'can be deleted' do
        expect { click_on 'Delete' }.to change{ DarkSkyArea.count }.from(1).to(0)
        expect(page).to have_content("There are no Dark Sky Areas.")
      end
    end
  end
end
