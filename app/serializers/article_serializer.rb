class ArticleSerializer < ApplicationSerializer
  attributes :id, :title, :content, :user_id, :created_at
end
