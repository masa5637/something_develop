# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

cpu_user = User.find_or_create_by!(email: "cpu_bot@arcana.local") do |u|
  u.password = SecureRandom.hex(16)
  u.username = "CPU"
end

def find_or_build_card(user, name, attrs)
  user.cards.find_or_create_by!(name: name) do |c|
    attrs.each { |k, v| c.send("#{k}=", v) }
  end
end

# ---- 弱デッキ用カード ----
easy_cards = [
  find_or_build_card(cpu_user, "錆びた剣士",   card_type: "monster", tier: 100, attack: 40,  defense: 60),
  find_or_build_card(cpu_user, "弱きゴブリン", card_type: "monster", tier: 100, attack: 60,  defense: 40),
  find_or_build_card(cpu_user, "小石の壁",     card_type: "monster", tier: 150, attack: 50,  defense: 100),
  find_or_build_card(cpu_user, "灯の精霊",     card_type: "monster", tier: 150, attack: 100, defense: 50),
  find_or_build_card(cpu_user, "弱火の矢",     card_type: "spell", effect_target: "enemy_monster", effect_action: "damage", effect_value: 20),
  find_or_build_card(cpu_user, "簡易治癒",     card_type: "spell", effect_target: "self_player",  effect_action: "heal",   effect_value: 15),
]

# ---- 中デッキ用カード ----
mid_cards = [
  find_or_build_card(cpu_user, "鉄壁の戦士",   card_type: "monster", tier: 200, attack: 100, defense: 100),
  find_or_build_card(cpu_user, "疾風の狼",     card_type: "monster", tier: 200, attack: 140, defense: 60),
  find_or_build_card(cpu_user, "森の番人",     card_type: "monster", tier: 150, attack: 70,  defense: 80),
  find_or_build_card(cpu_user, "雷光の射手",   card_type: "monster", tier: 150, attack: 110, defense: 40),
  find_or_build_card(cpu_user, "火炎弾",       card_type: "spell", effect_target: "enemy_monster", effect_action: "damage", effect_value: 40),
  find_or_build_card(cpu_user, "強化の儀式",   card_type: "spell", effect_target: "self_monster",  effect_action: "atk_up", effect_value: 30),
]

# ---- 強デッキ用カード ----
hard_cards = [
  find_or_build_card(cpu_user, "古龍ヴァルガ", card_type: "monster", tier: 300, attack: 200, defense: 100),
  find_or_build_card(cpu_user, "冥府の騎士",   card_type: "monster", tier: 300, attack: 150, defense: 150),
  find_or_build_card(cpu_user, "深淵の魔導士", card_type: "monster", tier: 200, attack: 160, defense: 40),
  find_or_build_card(cpu_user, "鋼鉄の守護者", card_type: "monster", tier: 200, attack: 60,  defense: 140),
  find_or_build_card(cpu_user, "破滅の一撃",   card_type: "spell", effect_target: "enemy_monster", effect_action: "destroy"),
  find_or_build_card(cpu_user, "暗黒の波動",   card_type: "spell", effect_target: "enemy_player",  effect_action: "damage", effect_value: 50),
]

# ---- 難易度ごとのデッキ作成 ----
def find_or_build_deck(user, name, cards)
  deck = user.decks.find_or_create_by!(name: name)
  cards.each do |card|
    deck.cards << card unless deck.cards.include?(card)
  end
  deck
end

find_or_build_deck(cpu_user, "CPU_EASY_DECK", easy_cards)
find_or_build_deck(cpu_user, "CPU_MID_DECK",  mid_cards)
find_or_build_deck(cpu_user, "CPU_HARD_DECK", hard_cards)

puts "CPU decks created!"