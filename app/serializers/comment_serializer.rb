class CommentSerializer < ApplicationSerializer
  attributes :id, :content, :user_id, :created_at, :article_id
end
