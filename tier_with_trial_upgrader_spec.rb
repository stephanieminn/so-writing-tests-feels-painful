RSpec.describe TierWithTrialUpgrader do
  describe "#upgrade" do
    let(:membership) { create(:membership, has_paid_subscription: true) }
    let(:tier) { create(:tier, name: "supporter") }

    context "when membership has subscription" do
      it "updates the subscription" do
        subscription = instance_spy(StripeSubscription)
        allow(StripeSubscription).to receive(:new).with(membership:).and_return(subscription)
        allow(subscription).to receive(:tier_name).and_return("supporter")
        trial = double(ends_at: 7.days.from_now)
        allow(Trial).to receive(:start).and_return(trial)

        TierWithTrialUpgrader.new(membership:, tier:).upgrade

        expect(subscription).to have_received(:update).with(
          from_tier: "supporter",
          to_tier: "club president",
          trial_end: trial.ends_at
        )
      end

      it "sends trial notification started for subscription" do
        membership = create(:membership, has_paid_subscription: true)
        tier = build(:tier)

        subscription = StripeSubscription.new(membership:)
        allow(StripeSubscription).to receive(:new).with(membership:).and_return(subscription)
        allow(subscription).to receive(:update)

        trial = build(:trial)
        allow(Trial).to receive(:start).and_return(trial)

        allow(SubscriptionNotifier).to receive(:notify_trial_started)

        TierWithTrialUpgrader.new(membership:, tier:).upgrade

        expect(SubscriptionNotifier)
          .to have_received(:notify_trial_started).with(subscription, trial)
      end
    end
  end
end
