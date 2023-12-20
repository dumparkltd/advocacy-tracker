require "rails_helper"
require "json"

RSpec.describe MembershipsController, type: :controller do
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:member) { FactoryBot.create(:actor) }
  let(:memberof) { FactoryBot.create(:actor, actortype: FactoryBot.create(:actortype, :with_members)) }

  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:membership) { FactoryBot.create(:membership, member: member, memberof: memberof) }
    subject { get :show, params: {id: membership}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a membership" do
        post :create, format: :json, params: {membership: {memberof_id: 1, member_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      subject do
        post :create,
          format: :json,
          params: {
            membership: {
              memberof_id: memberof.id,
              member_id: member.id
            }
          }
      end

      it "will not allow a guest to create a membership" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to create a membership" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a membership" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a membership" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {membership: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end

      it "will record what manager created the membership", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end
    end
  end

  describe "Delete destroy" do
    let(:subject) { delete :destroy, format: :json, params: {id: membership} }

    context "when signed in" do
      before { sign_in user }

      context "as a guest" do
        let(:user) { FactoryBot.create(:user) }

        context "with a membership not belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership) }

          it "will not allow you to delete a membership" do
            expect(subject).to be_forbidden
          end
        end

        context "with a membership belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership, created_by: user) }

          it "will not allow you to delete a membership" do
            expect(subject).to be_forbidden
          end
        end
      end

      context "as a manager" do
        let(:user) { FactoryBot.create(:user, :manager) }

        context "with a membership not belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership) }

          it "will not allow you to delete a membership" do
            expect(subject).to be_forbidden
          end
        end

        context "with a membership belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership, created_by: user) }

          it "will allow you to delete a membership" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as a coordinator" do
        let(:user) { FactoryBot.create(:user, :coordinator) }

        context "with a membership not belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership) }

          it "will not allow you to delete a membership" do
            expect(subject).to be_forbidden
          end
        end

        context "with a membership belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership, created_by: user) }

          it "will allow you to delete a membership" do
            expect(subject).to be_no_content
          end
        end
      end

      context "as an admin" do
        let(:user) { FactoryBot.create(:user, :admin) }

        context "with a membership not belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership) }

          it "will allow you to delete a membership" do
            expect(subject).to be_no_content
          end
        end

        context "with a membership belonging to the signed in user" do
          let(:membership) { FactoryBot.create(:membership, created_by: user) }

          it "will allow you to delete a membership" do
            expect(subject).to be_no_content
          end
        end
      end
    end
  end
end
