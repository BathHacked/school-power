require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ActivitiesController, type: :controller do
  let(:school) { FactoryGirl.create :school }
  let(:different_school) { FactoryGirl.create :school }
  let(:activity_category) { FactoryGirl.create :activity_category }
  let(:activity_type) { FactoryGirl.create(:activity_type, name: "One", activity_category: activity_category) }
  let(:activity_type2) { FactoryGirl.create(:activity_type, name: "Two", activity_category: activity_category) }

  let(:valid_attributes) {
    { school_id: school.id,
      activity_type_id: activity_type.id,
      activity_category_id: activity_category.id,
      title: 'test title',
      happened_on: Date.today
    }
  }

  let(:valid_attributes2) {
    { school_id: school.id,
      activity_type_id: activity_type2.id,
      activity_category_id: activity_category.id,
      title: 'test title',
      happened_on: Date.today
    }
  }

  let(:invalid_attributes) {
    { school_id: nil }
  }


  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end

    describe "GET #index" do
      it "assigns all school's activities as @activities" do
        activity = FactoryGirl.create :activity, school_id: school.id
        get :index, params: { school_id: school.id }
        expect(assigns(:activities)).to include activity
      end
      it "does not include activities from other schools" do
        activity = FactoryGirl.create :activity, school_id: different_school.id
        get :index, params: { school_id: school.id }
        expect(assigns(:activities)).not_to include activity
      end
    end

    describe "GET #show" do
      it "assigns the requested activity as @activity" do
        activity = FactoryGirl.create :activity, school_id: school.id
        get :show, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity)).to eq(activity)
      end
    end

    describe "GET #new" do
      it "assigns a new activity as @activity" do
        get :new, params: { school_id: school.id }
        expect(assigns(:activity)).to be_a_new(Activity)
      end
    end

    describe "GET #edit" do
      it "assigns the requested activity as @activity" do
        activity = FactoryGirl.create :activity, school_id: school.id
        get :edit, params: { school_id: school.id, id: activity.to_param }
        expect(assigns(:activity)).to eq(activity)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Activity" do
          expect {
            post :create, params: { school_id: school.id, activity: valid_attributes }
          }.to change(Activity, :count).by(1)
        end

        it "assigns a newly created activity as @activity" do
          post :create, params: { school_id: school.id, activity: valid_attributes }
          expect(assigns(:activity)).to be_a(Activity)
          expect(assigns(:activity)).to be_persisted
        end

        it 'adds correct points to the school' do
          expect {
            post :create, params: { school_id: school.id, activity: valid_attributes }
          }.to change { school.points }.by(activity_type.score)
        end

        it 'adds badge when activity created' do
          post :create, params: { school_id: school.id, activity: valid_attributes }
          school.reload
          expect( school.badges.first.name ).to eql('first-activity')
        end

        it "redirects to the activity" do
          post :create, params: { school_id: school.id, activity: valid_attributes }
          expect(response).to redirect_to(school_activity_path(school, Activity.last))
        end

        it "assigns all-activities badge" do
          post :create, params: { school_id: school.id, activity: valid_attributes }
          #should now have first activity
          post :create, params: { school_id: school.id, activity: valid_attributes2 }
          #should now have all-activities, and all-categories
          school.reload
          expect( school.activities.length ).to eql(2)
          expect( school.badges.length ).to eql(3)
          expect( school.badges[0].name ).to eql('first-activity')
          expect( school.badges[1].name ).to eql('all-categories')
          expect( school.badges[2].name ).to eql('all-activities')
        end

        it "assigns badge for 10 activities" do
          9.times do
            post :create, params: { school_id: school.id, activity: valid_attributes }
          end
          #should now have
          #first activity, all-activities, all-categories
          school.reload
          expect( school.badges.length ).to eql(3)
          post :create, params: { school_id: school.id, activity: valid_attributes }
          school.reload
          expect( school.badges.length ).to eql(4)
          expect( school.badges.last.name ).to eql('ten-activities')
        end

        it "assigns evidence badge when there's a link" do
          valid_attributes[:description] = "This is a test. <a href='http://example.org'>link</a>."
          post :create, params: { school_id: school.id, activity: valid_attributes }
          school.reload
          expect( school.badges.last.name ).to eql('evidence')
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved activity as @activity" do
          post :create, params: { school_id: school.id, activity: invalid_attributes }
          expect(assigns(:activity)).to be_a_new(Activity)
        end

        it 'does not add 10 points to the school' do
          expect {
            post :create, params: { school_id: school.id, activity: invalid_attributes }
          }.not_to change { school.points }
        end

        it "re-renders the 'new' template" do
          post :create, params: { school_id: school.id, activity: invalid_attributes }
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          { title: 'new_title',
            description: 'new_description',
            activity_type_id: activity_type2.id,
            happened_on: Date.today
          }
        }

        it "updates the requested activity" do
          activity = Activity.create! valid_attributes
          put :update, params: { school_id: school.id, id: activity.to_param, activity: new_attributes }
          activity.reload
          expect(activity.title).to eq new_attributes[:title]
          expect(activity.description).to eq new_attributes[:description]
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

    describe "DELETE #destroy" do
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
  end
end
