class ProgressInformation < ApplicationRecord
  belongs_to :article

  validates :content, presence: true
end
