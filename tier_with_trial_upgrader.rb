class TierWithTrialUpgrader
  def initialize(membership:, tier:)
    @membership = membership
    @tier = tier
  end

  def upgrade
    trial = start_trial

    if membership.has_paid_subscription?
      subscription.notified_update_with_trial(tier, trial)
    end

    membership.update!(tier:)
  end

  private

  attr_reader :membership, :tier

  def subscription
    @subscription ||= StripeSubscription.new(membership:)
  end

  def start_trial
    Trial.start(
      membership:,
      tier:,
      starts_at: Time.current,
      days: tier.trial_length
    )
  end
end
