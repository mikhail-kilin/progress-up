class SubscriptionSerializer < ApplicationSerializer
  attributes :id, :entity_id, :entity_type, :user_id, :created_at
end
