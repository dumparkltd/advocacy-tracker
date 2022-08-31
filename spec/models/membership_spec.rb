require "rails_helper"

RSpec.describe Membership, type: :model do
  it { is_expected.to belong_to :member }
  it { is_expected.to belong_to :memberof }

  let(:member) { FactoryBot.create(:actor) }
  let(:memberof) { FactoryBot.create(:actor, actortype: FactoryBot.create(:actortype, :with_members)) }

  it "errors when the member is the same as the memberof" do
    membership = described_class.create(member: member, memberof: member)
    expect(membership).to be_invalid
    expect(membership.errors[:member]).to include("can't be the same as memberof")
  end

  it "works when the memberof can have members" do
    membership = described_class.create(member: member, memberof: memberof)
    expect(membership).to be_valid
  end

  context "with a member and a memberof" do
    it "create sets the relationship_updated_at on the member" do
      expect { described_class.create(member: member, memberof: memberof) }
        .to change { member.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the memberof" do
      expect { described_class.create(member: member, memberof: memberof) }
        .to change { memberof.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the member" do
      relationship = described_class.create(member: member, memberof: memberof)
      expect { relationship.touch }.to change { member.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the memberof" do
      relationship = described_class.create(member: member, memberof: memberof)
      expect { relationship.touch }.to change { memberof.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the member" do
      relationship = described_class.create(member: member, memberof: memberof)
      expect { relationship.destroy }.to change { member.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the memberof" do
      relationship = described_class.create(member: member, memberof: memberof)
      expect { relationship.destroy }.to change { memberof.reload.relationship_updated_at }
    end
  end
end
