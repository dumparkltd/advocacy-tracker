require "rails_helper"
require "json"

RSpec.describe MeasureIndicatorsController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:measure_indicator) { FactoryBot.create(:measure_indicator) }
    subject { get :show, params: {id: measure_indicator}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a measure_indicator" do
        post :create, format: :json, params: {measure_indicator: {measure_id: 1, indicator_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:measure) { FactoryBot.create(:measure) }
      let(:indicator) { FactoryBot.create(:indicator) }

      subject do
        post :create,
          format: :json,
          params: {
            measure_indicator: {
              measure_id: measure.id,
              indicator_id: indicator.id
            }
          }
      end

      it "will not allow a guest to create a measure_indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a coordinator to create a measure_indicator" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will allow a manager to create a measure_indicator" do
        sign_in user
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in user
        post :create, format: :json, params: {measure_indicator: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:subject) { delete :destroy, format: :json, params: {id: measure_indicator} }

    context "when signed in" do
      before { sign_in user }

      context "as a guest" do
        let(:user) { FactoryBot.create(:user) }

        context "with a measure_indicator not belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator) }

          it "will not allow you to delete a measure_indicator" do
            expect(subject).to be_forbidden
          end
        end

        context "with a measure_indicator belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator, created_by: user) }

          it "will not allow you to delete a measure_indicator" do
            expect(subject).to be_forbidden
          end
        end
      end

      context "as a manager" do
        let(:user) { FactoryBot.create(:user, :manager) }

        context "with a measure_indicator not belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator) }

          it "will not allow you to delete a measure_indicator" do
            expect(subject).to be_forbidden
          end
        end

        context "with a measure_indicator belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator, created_by: user) }

          it "will allow you to delete a measure_indicator" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as a coordinator" do
        let(:user) { FactoryBot.create(:user, :coordinator) }

        context "with a measure_indicator not belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator) }

          it "will not allow you to delete a measure_indicator" do
            expect(subject).to be_forbidden
          end
        end

        context "with a measure_indicator belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator, created_by: user) }

          it "will allow you to delete a measure_indicator" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as an admin" do
        let(:user) { FactoryBot.create(:user, :admin) }

        context "with a measure_indicator not belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator) }

          it "will allow you to delete a measure_indicator" do
            expect(subject).to be_no_content
          end
        end

        context "with a measure_indicator belonging to the signed in user" do
          let(:measure_indicator) { FactoryBot.create(:measure_indicator, created_by: user) }

          it "will allow you to delete a measure_indicator" do
            expect(subject).to be_no_content
          end
        end
      end
    end
  end
end
