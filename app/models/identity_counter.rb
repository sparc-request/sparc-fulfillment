class IdentityCounter < ActiveRecord::Base

  belongs_to :identity

  # Ex. to increment tasks_count:
  # IdentityCounter.update_counter(id, :tasks, 1)
  def self.update_counter(identity_id, counter, amount)
    identity_counter = IdentityCounter.find_or_create_by(identity_id: identity_id)
    counter_name = counter.to_s + "_count"
    next_count = identity_counter.read_attribute(counter_name) + amount
    if next_count >= 0
      identity_counter.update_attribute(counter_name, next_count)
    end
  end
end
