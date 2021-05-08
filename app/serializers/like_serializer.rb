class LikeSerializer < ApplicationSerializer
  attributes :id, :user_id, :created_at, :article_id
end
