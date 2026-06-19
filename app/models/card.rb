class Card < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  TIERS = [300, 200, 150, 100].freeze

  EFFECT_TARGETS = {
    "enemy_monster"     => "相手モンスター1体",
    "enemy_all_monster"  => "相手モンスター全体",
    "self_monster"       => "自分のモンスター1体",
    "enemy_player"       => "相手プレイヤー（HP）",
    "self_player"        => "自分のプレイヤー（HP）"
  }.freeze

  EFFECT_ACTIONS = {
    "destroy"     => "破壊（即死）させる",
    "damage"      => "ダメージを与える",
    "heal"        => "HPを回復させる",
    "atk_up"      => "ATKを上昇させる",
    "atk_down"    => "ATKを下降させる"
  }.freeze

  # 数値指定が必要な効果
  ACTIONS_REQUIRE_VALUE = %w[damage heal atk_up atk_down].freeze

  validates :name, presence: true
  validates :card_type, inclusion: { in: %w[monster spell] }

  with_options if: -> { card_type == "monster" } do
    validates :tier, inclusion: { in: TIERS }
    validates :attack, :defense, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate :stats_match_tier
  end

  with_options if: -> { card_type == "spell" } do
    validates :effect_target, inclusion: { in: EFFECT_TARGETS.keys }
    validates :effect_action, inclusion: { in: EFFECT_ACTIONS.keys }
    validates :effect_value, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: -> { ACTIONS_REQUIRE_VALUE.include?(effect_action) }
  end

  def monster?
    card_type == "monster"
  end

  def spell?
    card_type == "spell"
  end

  def effect_description
    return nil unless spell?
    target_text = EFFECT_TARGETS[effect_target]
    action_text = EFFECT_ACTIONS[effect_action]
    if ACTIONS_REQUIRE_VALUE.include?(effect_action)
      "#{target_text}に#{effect_value}の#{action_text}"
    else
      "#{target_text}を#{action_text}"
    end
  end

  private

  def stats_match_tier
    return if attack.nil? || defense.nil? || tier.nil?
    if attack + defense != tier
      errors.add(:base, "攻撃力と防御力の合計は#{tier}族と一致させてください（現在: #{attack + defense}）")
    end
  end
end