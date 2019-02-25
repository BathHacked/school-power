require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  let(:school) { create :school }
  let(:different_school) { create :school }
  let!(:activity_category) { create :activity_category }
  let!(:activity_type) { create(:activity_type, name: "One", activity_category: activity_category, data_driven: true) }
  let(:activity_type2) { create(:activity_type, name: "Two", activity_category: activity_category) }

  let(:valid_attributes) {
    { school_id: school.id,
      activity_type_id: activity_type.id,
      activity_category_id: activity_category.id,
      title: 'test title',
      content: '<div>Content</div>',
      happened_on: Date.today
    }
  }

  let(:invalid_attributes) {
    { school_id: nil }
  }

  describe "GET #index" do
    it "assigns all school's activities as @activities" do
      activity = create :activity, school_id: school.id
      get :index, params: { school_id: school.id }
      expect(assigns(:activities)).to include activity
    end
    it "does not include activities from other schools" do
      activity = create :activity, school_id: different_school.id
      get :index, params: { school_id: school.id }
      expect(assigns(:activities)).not_to include activity
    end
  end

  describe "GET #show" do
    it "assigns the requested activity as @activity" do
      activity = create :activity, school_id: school.id
      get :show, params: { school_id: school.id, id: activity.to_param }
      expect(assigns(:activity)).to eq(activity)
    end
  end

  describe "GET #new" do
    context "As an admin user" do
      before(:each) do
        sign_in_user(:admin)
      end
      it "assigns a new activity as @activity" do
        get :new, params: { school_id: school.id }
        expect(assigns(:activity)).to be_a_new(Activity)
      end
      it "properly defaults the category and activity" do
        get :new, params: { school_id: school.id, activity_type_id: activity_type2.id }
        expect(assigns(:activity)).to be_a_new(Activity)
        expect(assigns(:activity).activity_type).to eql(activity_type2)
        expect(assigns(:activity).activity_category).to eql(activity_category)
      end
    end

    it "redirects when not authorised" do
      get :new, params: { school_id: school.id }
      expect(response).to have_http_status(:redirect  )
    end

  end

  describe "GET #edit" do
    before(:each) do
      sign_in_user(:admin)
    end

    it "assigns the requested activity as @activity" do
      activity = create :activity, school_id: school.id
      get :edit, params: { school_id: school.id, id: activity.to_param }
      expect(assigns(:activity)).to eq(activity)
    end
  end

  describe "POST #create" do
    before(:each) do
      sign_in_user(:admin)
    end

    context "with invalid params" do
      before(:each) do
        post :create, params: { school_id: school.id, activity: invalid_attributes }
      end
      it "assigns a newly created but unsaved activity as @activity" do
        expect(assigns(:activity)).to be_a_new(Activity)
      end

      it 'does not add points to the school' do
        school.reload
        expect( school.points ).to eql(0)
      end

      it "re-renders the 'new' template" do
        expect(response).to render_template("new")
      end
    end

    context "with valid params" do
      before(:each) do
        post :create, params: { school_id: school.id, activity: valid_attributes }
      end

      it "creates a new Activity" do
        expect(Activity.count).to eql(1)
      end

      it "assigns a newly created activity as @activity" do
        expect(assigns(:activity)).to be_a(Activity)
        expect(assigns(:activity)).to be_persisted
      end

      it "redirects to the activity" do
        expect(response).to redirect_to(school_activity_path(school, Activity.last))
      end

      it 'adds correct points to the school' do
        school.reload
        expect(school.points).to eql(activity_type.score)
      end

      it 'adds badges' do
        school.reload
        expect( school.badges.first.name ).to eql('beginner')
      end

    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      sign_in_user(:admin)
    end

    it "destroys the requested activity" do
      activity = Activity.create! valid_attributes
      expect {
        delete :destroy, params: { school_id: school.id, id: activity.to_param }
      }.to change(Activity, :count).by(-1)
    end

    it "redirects to the activities index" do
      activity = Activity.create! valid_attributes
      delete :destroy, params: { school_id: school.id, id: activity.to_param }
      expect(response).to redirect_to(school_activities_path(school))
    end
  end

  describe "PUT #update" do
    before(:each) do
      sign_in_user(:admin)
    end

    context "with valid params" do
      let(:new_attributes) {
        { title: 'new_title',
          content: 'new_description',
          activity_type_id: activity_type2.id,
          happened_on: Date.today
        }
      }

      it "updates the requested activity" do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: new_attributes }
        activity.reload
        expect(activity.title).to eq new_attributes[:title]
        expect(activity.content.to_plain_text).to eq new_attributes[:content]
        expect(activity.activity_type_id).to eq new_attributes[:activity_type_id]
        expect(activity.happened_on).to eq new_attributes[:happened_on]
      end

      it "assigns the requested activity as @activity" do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: valid_attributes }
        expect(assigns(:activity)).to eq(activity)
      end

      it "redirects to the activity" do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: valid_attributes }
        expect(response).to redirect_to(school_activity_path(school, activity))
      end
    end

    context "with invalid params" do
      it "assigns the activity as @activity" do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: invalid_attributes }
        expect(assigns(:activity)).to eq(activity)
      end

      it "re-renders the 'edit' template" do
        activity = Activity.create! valid_attributes
        put :update, params: { school_id: school.id, id: activity.to_param, activity: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

end
