require 'rails_helper'

RSpec.describe SchoolsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # School. As you add validations to School, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {urn: 12345, name: 'test school'}
  }

  let(:invalid_attributes) {
    {name: nil}
  }

  describe 'GET #suggest_activity' do
    let(:school) { FactoryBot.create :school }

    context "as a guest user" do
      it "is not authorised" do
        get :suggest_activity, params: { id: school.to_param }
        expect(response).to have_http_status(:redirect  )
      end
    end
    context "as an authorised school administrator" do

      let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
      let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
      let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }
      let!(:school) { create :school, active: true, key_stages: [ks1_tag, ks3_tag] }

      let(:activity_category) { create :activity_category }
      let!(:activity_types) { create_list(:activity_type, 5, activity_category: activity_category, data_driven: true, key_stages: [ks1_tag, ks2_tag]) }

      before(:each) { sign_in_user(:school_user, school.id) }

      context "with a single activity type" do
        it "is authorised" do
          get :suggest_activity, params: { id: school.to_param }
          expect(response).to_not have_http_status(:redirect  )
          expect(assigns(:suggestions)).to match_array(activity_types)
        end
      end

      context "with no activity types set for the school" do
        it "suggests any 5 if no suggestions" do
          get :suggest_activity, params: { id: school.to_param }
          expect(assigns(:suggestions)).to match_array(activity_types)
        end
      end

      context "with initial suggestions" do
        let!(:activity_types_with_suggestions) { create_list(:activity_type, 5, :as_initial_suggestions, key_stages: [ks1_tag, ks2_tag])}
        it "suggests the first five initial suggestions" do
          get :suggest_activity, params: { id: school.to_param }
          expect(assigns(:suggestions)).to match_array(activity_types_with_suggestions)
        end
      end

      context "with suggestions based on last activity type" do
        let!(:activity_type_with_further_suggestions) { create :activity_type, :with_further_suggestions, number_of_suggestions: 5 }
        let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

        it "suggests the five follow ons from original" do
          get :suggest_activity, params: { id: school.to_param }
          expect(assigns(:suggestions)).to match_array(last_activity.activity_type.activity_type_suggestions.map(&:suggested_type))
        end
      end
    end
  end

  describe "GET #index" do
    it "assigns schools that are active but not grouped as @ungrouped_active_schools" do
      school = FactoryBot.create :school, active: true
      get :index, params: {}
      expect(assigns(:ungrouped_active_schools)).to eq([school])
    end
    it "assigns inactive schools as @schools_not_active" do
      school = FactoryBot.create :school, active: false
      get :index, params: {}
      expect(assigns(:schools_not_active)).to eq([school])
    end
  end

  describe "GET #show" do
    context "as a guest user" do
      before(:each) do
        sign_in_user(:guest)
      end
      context "when the school is not active" do
        it "redirects to the unauthorised page" do
          sign_in_user(:guest)
          school = FactoryBot.create :school, active: false
          get :show, params: {id: school.to_param}
          expect(response).to redirect_to(root_path)
        end
      end
      context "the school is active" do
        it "assigns the requested school as @school" do
          school = FactoryBot.create :school
          get :show, params: {id: school.to_param}
          expect(assigns(:school)).to eq(school)
        end
        it "assigns the school's meters as @meters" do
          school = FactoryBot.create :school
          meter = FactoryBot.create :gas_meter, school_id: school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:meters)).to include(meter)
        end
        it "assigns the latest activities as @activities" do
          school = FactoryBot.create :school
          activity = FactoryBot.create :activity, school_id: school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:activities)).to include(activity)
        end
        it "does not include activities from other schools" do
          school = FactoryBot.create :school
          other_school = FactoryBot.create :school
          FactoryBot.create :activity, school_id: school.id
          activity_other_school = FactoryBot.create :activity, school_id: other_school.id
          get :show, params: {id: school.to_param}
          expect(assigns(:activities)).not_to include activity_other_school
        end
        it "assigns the school's awards to @badges" do
          school = create :school, :with_badges, badges_sashes: 7

          get :show, params: {id: school.to_param}
          expect(assigns(:badges)).to include(school.badges.first)
        end
        it "doesn't include other schools badges" do
          school_one, school_two = create_pair :school, :with_badges, badges_sashes: 2

          get :show, params: {id: school_one.to_param}
          expect(assigns(:badges)).not_to include(school_two.badges.first)
        end
      end
    end
    context "as an admin user" do
      before(:each) do
        sign_in_user(:admin)
      end

    end
  end

  describe "GET #awards" do
    it 'assigns awards as @badges' do
      school = create :school, :with_badges

      get :awards, params: {id: school.to_param}
      expect(assigns(:badges)).to include(school.badges.first)
    end
  end

  describe "GET #usage" do
    let!(:school) { FactoryBot.create :school }
    let(:period) { :daily }
    let(:supply) { :electricity }
    it "assigns the requested school as @school" do
      get :usage, params: {id: school.to_param, period: period, supply: supply}
      expect(assigns(:school)).to eq(school)
    end
    context "to_date is specified" do
      let(:to_date) { Date.current - 1.days }
      it "assigns to_date to @to_date" do
        get :usage, params: {id: school.to_param, period: period, to_date: to_date, supply: supply}
        expect(assigns(:to_date)).to eq to_date.beginning_of_week(:sunday)
      end
    end
    context "period is 'daily'" do
      let(:period) { :daily }
      it "renders the daily_usage template" do
        get :usage, params: {id: school.to_param, period: period, supply: supply}
        expect(response).to render_template('daily_usage')
      end
    end
    context "period is 'hourly'" do
      let(:period) { :hourly }
      it "renders the hourly_usage template" do
        get :usage, params: {id: school.to_param, period: period, supply: supply}
        expect(response).to render_template('hourly_usage')
      end
    end
    context "period is not specified" do
      let(:period) { nil }
      it "renders the hourly_usage template" do
        get :usage, params: {id: school.to_param, period: period, supply: supply}
        expect(response).to render_template('hourly_usage')
      end
    end

    context 'when supply is not provided' do
      context 'where the school has no meters with readings' do
        it 'redirects to the school page' do
          get :usage, params: {id: school.to_param}
          expect(response).to redirect_to(school_path(school.to_param))
        end
      end
      context 'where the school only has an electricity meter with readings' do
        it 'sets the supply to electricity' do
          create(:electricity_meter_with_reading, school: school)
          get :usage, params: {id: school.to_param}
          expect(assigns(:supply)).to eq('electricity')
        end
      end
      context 'where the school only has a gas meter with readings' do
        it 'sets the supply to gas' do
          create(:gas_meter_with_reading, school: school)
          get :usage, params: {id: school.to_param}
          expect(assigns(:supply)).to eq('gas')
        end
      end
      context 'where the school has both' do
        it 'sets the supply to electricity' do
          create(:electricity_meter_with_reading, school: school)
          create(:gas_meter_with_reading, school: school)
          get :usage, params: {id: school.to_param}
          expect(assigns(:supply)).to eq('electricity')
        end
      end

    end
  end

  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end

    describe "GET #new" do
      it "assigns a new school as @school" do
        get :new, params: {}
        expect(assigns(:school)).to be_a_new(School)
      end
    end

    describe "GET #edit" do
      it "assigns the requested school as @school" do
        school = FactoryBot.create :school
        get :edit, params: {id: school.to_param}
        expect(assigns(:school)).to eq(school)
      end
    end

    describe "POST #create" do
      context "with valid params" do

        it "creates a new School" do
          expect {
            post :create, params: {school: valid_attributes}
          }.to change(School, :count).by(1)
        end
        it "assigns a newly created school as @school" do
          post :create, params: {school: valid_attributes}
          expect(assigns(:school)).to be_a(School)
          expect(assigns(:school)).to be_persisted
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved school as @school" do
          post :create, params: {school: invalid_attributes}
          expect(assigns(:school)).to be_a_new(School)
        end

        it "re-renders the 'new' template" do
          post :create, params: {school: invalid_attributes}
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          {name: 'new name'}
        }

        it "updates the requested school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: new_attributes}
          school.reload
          expect(school.name).to eq new_attributes[:name]
        end

        it "assigns the requested school as @school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: valid_attributes}
          expect(assigns(:school)).to eq(school)
        end

        it "redirects to the school" do
          school = create(:school_with_same_name)
          put :update, params: {id: school.to_param, school: valid_attributes}
          expect(response).to redirect_to(school)
        end

      end

      context "with invalid params" do
        it "assigns the school as @school" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: invalid_attributes}
          expect(assigns(:school)).to eq(school)
        end

        it "re-renders the 'edit' template" do
          school = FactoryBot.create :school
          put :update, params: {id: school.to_param, school: invalid_attributes}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested school" do
        school = FactoryBot.create :school
        expect {
          delete :destroy, params: {id: school.to_param}
        }.to change(School, :count).by(-1)
      end

      it "redirects to the schools list" do
        school = FactoryBot.create :school
        delete :destroy, params: {id: school.to_param}
        expect(response).to redirect_to(schools_url)
      end
    end

  end
end
