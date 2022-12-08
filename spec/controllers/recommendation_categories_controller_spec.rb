require "rails_helper"
require "json"

RSpec.describe RecommendationCategoriesController, type: :controller do
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:recommendation_category) { FactoryBot.create(:recommendation_category) }
    subject { get :show, params: {id: recommendation_category}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a recommendation_category" do
        post :create, format: :json, params: {recommendation_category: {recommendation_id: 1, category_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:category) { FactoryBot.create(:category) }

      subject do
        post :create,
          format: :json,
          params: {
            recommendation_category: {
              recommendation_id: recommendation.id,
              category_id: category.id
            }
          }
      end

      it "will not allow a guest to create a recommendation_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a recommendation_category" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a recommendation_category" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {recommendation_category: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:subject) { delete :destroy, format: :json, params: {id: recommendation_category} }

    context "when signed in" do
      before { sign_in user }

      context "as a guest" do
        let(:user) { FactoryBot.create(:user) }

        context "with a recommendation_category not belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category) }

          it "will not allow you to delete a recommendation_category" do
            expect(subject).to be_forbidden
          end
        end

        context "with a recommendation_category belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category, created_by: user) }

          it "will not allow you to delete a recommendation_category" do
            expect(subject).to be_forbidden
          end
        end
      end

      context "as a manager" do
        let(:user) { FactoryBot.create(:user, :manager) }

        context "with a recommendation_category not belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category) }

          it "will not allow you to delete a recommendation_category" do
            expect(subject).to be_forbidden
          end
        end

        context "with a recommendation_category belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category, created_by: user) }

          it "will allow you to delete a recommendation_category" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as a coordinator" do
        let(:user) { FactoryBot.create(:user, :coordinator) }

        context "with a recommendation_category not belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category) }

          it "will not allow you to delete a recommendation_category" do
            expect(subject).to be_forbidden
          end
        end

        context "with a recommendation_category belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category, created_by: user) }

          it "will allow you to delete a recommendation_category" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as an admin" do
        let(:user) { FactoryBot.create(:user, :admin) }

        context "with a recommendation_category not belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category) }

          it "will allow you to delete a recommendation_category" do
            expect(subject).to be_no_content
          end
        end

        context "with a recommendation_category belonging to the signed in user" do
          let(:recommendation_category) { FactoryBot.create(:recommendation_category, created_by: user) }

          it "will allow you to delete a recommendation_category" do
            expect(subject).to be_no_content
          end
        end
      end
    end
  end
end
