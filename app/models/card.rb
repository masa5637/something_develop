class Card < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :name, presence: true
  validates :attack, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :defense, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
