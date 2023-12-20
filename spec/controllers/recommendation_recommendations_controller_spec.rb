require "rails_helper"
require "json"

RSpec.describe RecommendationRecommendationsController, type: :controller do
  describe "index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "show" do
    let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }
    subject { get :show, params: {id: recommendation_recommendation}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "create" do
    context "when not signed in" do
      it "doesnt allow creating a recommendation_recommendation" do
        post :create, format: :json, params: {recommendation_recommendation: {recommendation_id: 1, other_recommendation_id: 2}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:recommendation_1) { FactoryBot.create(:recommendation) }
      let(:recommendation_2) { FactoryBot.create(:recommendation) }

      subject do
        post :create,
          format: :json,
          params: {
            recommendation_recommendation: {
              recommendation_id: recommendation_1,
              other_recommendation_id: recommendation_2
            }
          }
      end

      it "wont allow a guest to create a recommendation_recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a recommendation_recommendation" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow an admin to create a recommendation_recommendation" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {recommendation_recommendation: {description: "desc"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:subject) { delete :destroy, format: :json, params: {id: recommendation_recommendation} }

    context "when signed in" do
      before { sign_in user }

      context "as a guest" do
        let(:user) { FactoryBot.create(:user) }

        context "with a recommendation_recommendation not belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }

          it "will not allow you to delete a recommendation_recommendation" do
            expect(subject).to be_forbidden
          end
        end

        context "with a recommendation_recommendation belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation, created_by: user) }

          it "will not allow you to delete a recommendation_recommendation" do
            expect(subject).to be_forbidden
          end
        end
      end

      context "as a manager" do
        let(:user) { FactoryBot.create(:user, :manager) }

        context "with a recommendation_recommendation not belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }

          it "will not allow you to delete a recommendation_recommendation" do
            expect(subject).to be_forbidden
          end
        end

        context "with a recommendation_recommendation belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation, created_by: user) }

          it "will allow you to delete a recommendation_recommendation" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as a coordinator" do
        let(:user) { FactoryBot.create(:user, :coordinator) }

        context "with a recommendation_recommendation not belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }

          it "will not allow you to delete a recommendation_recommendation" do
            expect(subject).to be_forbidden
          end
        end

        context "with a recommendation_recommendation belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation, created_by: user) }

          it "will allow you to delete a recommendation_recommendation" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as an admin" do
        let(:user) { FactoryBot.create(:user, :admin) }

        context "with a recommendation_recommendation not belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }

          it "will allow you to delete a recommendation_recommendation" do
            expect(subject).to be_no_content
          end
        end

        context "with a recommendation_recommendation belonging to the signed in user" do
          let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation, created_by: user) }

          it "will allow you to delete a recommendation_recommendation" do
            expect(subject).to be_no_content
          end
        end
      end
    end
  end

  describe "update" do
    let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }

    it "doesnt allow updates" do
      expect(put: "recommendation_recommendations/42").not_to be_routable
    end
  end
end
