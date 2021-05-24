require 'rails_helper'

describe SchoolRemover, :schools, type: :service do

  let(:school) { create(:school, visible: false) }
  let!(:school_admin) { create(:school_admin, school: school) }
  let!(:meter) { create(:electricity_meter, school: school) }

  let(:service) { SchoolRemover.new(school) }

  describe '#remove_school!' do
    it 'marks the school as inactive and sets removal date' do
      service.remove_school!
      expect(school.active).to be_falsey
      expect(school.process_data).to be_falsey
      expect(school.removal_date).to eq(Time.zone.today)
    end

    it 'fails if school is visible' do
      school.update(visible: true)
      expect {
        service.remove_school!
      }.to raise_error(SchoolRemover::Error)
    end
  end

  describe '#remove_users!' do
    it 'locks the user account' do
      service.remove_users!
      expect(school.users.all?(&:access_locked?)).to be_truthy
      expect(school.users.all?{|u| u.email.include?('removed')}).to be_truthy
    end
  end

  describe '#remove_meters!' do
    it 'deactivates the meters' do
      expect_any_instance_of(MeterManagement).to receive_messages([:deactivate_meter!, :remove_data!])
      service.remove_meters!
    end
  end

  # remove school from user cluster schools
  # remove alert contacts

  # remove onboarding?
  # remove calendars?

end
