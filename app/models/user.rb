class User < ApplicationRecord
  has_secure_password

  has_many :subscribes, as: :entity, class_name: "Subscription", dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :articles, dependent: :destroy

  validates :email, presence: true
  validates :password, length: { minimum: 6 }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  mount_uploader :avatar, ::AvatarUploader
end
