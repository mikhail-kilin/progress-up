class UserSerializer < ApplicationSerializer
  attributes :id, :email, :full_name, :phone, :description, :avatar_url, :article_ids

  def avatar_url
    object.avatar.url
  end
end
