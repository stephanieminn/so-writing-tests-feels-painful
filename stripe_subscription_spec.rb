RSpec.describe StripeSubscription do
  describe "#notified_update_with_trial" do
    it "updates subscription and sends notification" do
      to_tier = build(:tier)
      trial = build(:trial)
      subscription = build(:subscription)

      allow(subscription).to receive(:update)
      allow(SubscriptionTrialMailer).to receive(:notify_trial_started)

      subscription.notified_update_with_trial(tier, trial)

      expect(subscription).to_have received(:update).with(
        from_tier: subscription.tier,
        to_tier:,
        trial_end: trial.ends_at
      )
      expect(SubscriptionNotifier)
        .to have_received(:notify_trial_started).with(subscription, trial)
    end
  end
end
