# app/models/deck.rb
class Deck < ApplicationRecord
  belongs_to :user
  has_many :deck_cards, dependent: :destroy
  has_many :cards, through: :deck_cards

  MAX_CARDS = 20
  MIN_MONSTER = 5
  MIN_SPELL = 5
  MAX_TIER_300 = 2

  def monster_count
    cards.where(card_type: "monster").count
  end

  def spell_count
    cards.where(card_type: "spell").count
  end

  def tier_300_count
    cards.where(card_type: "monster", tier: 300).count
  end

  def total_count
    cards.count
  end

  def valid_for_battle?
    total_count <= MAX_CARDS &&
      monster_count >= MIN_MONSTER &&
      spell_count >= MIN_SPELL &&
      tier_300_count <= MAX_TIER_300
  end
end