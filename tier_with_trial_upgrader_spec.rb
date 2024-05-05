RSpec.describe TierWithTrialUpgrader do
  describe "#upgrade" do
    context "when membership has subscription" do
      it "sends trial started notification for subscription" do
        membership = create(:membership, has_paid_subscription: true)
        tier = build(:tier)

        subscription = StripeSubscription.new(membership:)
        allow(StripeSubscription).to receive(:new).and_return(subscription)

        trial = build(:trial)
        allow(Trial).to receive(:start).and_return(trial)

        TierWithTrialUpgrader.new(membership:, tier:).upgrade

        expect(subscription)
          .to have_received(:notified_update_with_trial).with(tier, trial)
      end
    end
  end
end
