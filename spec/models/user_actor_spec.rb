require "rails_helper"

RSpec.describe UserActor, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :actor }
  # handled by postgres
  # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:actor_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:actor_id) }

  context "with an actor and a user" do
    let(:actor) { FactoryBot.create(:actor) }
    let(:user) { FactoryBot.create(:user) }

    it "create sets the relationship_updated_at on the actor" do
      expect { described_class.create(actor: actor, user: user) }
        .to change { actor.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the user" do
      expect { described_class.create(actor: actor, user: user) }
        .to change { user.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the actor" do
      relationship = described_class.create(actor: actor, user: user)
      expect { relationship.touch }.to change { actor.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the user" do
      relationship = described_class.create(actor: actor, user: user)
      expect { relationship.touch }.to change { user.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the actor" do
      relationship = described_class.create(actor: actor, user: user)
      expect { relationship.destroy }.to change { actor.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the user" do
      relationship = described_class.create(actor: actor, user: user)
      expect { relationship.destroy }.to change { user.reload.relationship_updated_at }
    end
  end
end
