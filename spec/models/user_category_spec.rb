require "rails_helper"

RSpec.describe UserCategory, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:category_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:category_id) }

  context "with a user" do
    let(:user) { FactoryBot.create(:user) }

    it "should set the relationship_updated_at on the user" do
      expect { FactoryBot.create(:user_category, user: user) }
        .to change { user.reload.relationship_updated_at }
    end
  end
end
