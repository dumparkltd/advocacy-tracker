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

    let(:whodunnit) { FactoryBot.create(:user).id }
    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    subject { described_class.create(actor: actor, user: user) }

    it "create sets the relationship_updated_at on the actor" do
      expect { subject }.to change { actor.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the user" do
      expect { subject }.to change { user.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the actor" do
      subject
      expect { subject.touch }.to change { actor.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the user" do
      subject
      expect { subject.touch }.to change { user.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the actor" do
      expect { subject.destroy }.to change { actor.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_by_id on the actor" do
      expect { subject }.to change { actor.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "create sets the relationship_updated_by_id on the user" do
      expect { subject }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the actor" do
      subject
      actor.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { actor.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the user" do
      subject
      user.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the actor" do
      expect { subject.destroy }.to change { actor.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end
end
