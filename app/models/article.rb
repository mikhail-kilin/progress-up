class Article < ApplicationRecord
  belongs_to :user
  has_many :subscriptions, as: :entity, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :progress_informations, dependent: :destroy

  validates :title, :content, presence: true
end
