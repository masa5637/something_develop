class Game < ApplicationRecord
  belongs_to :user

  PLAYER_START_HP = 2000
  CPU_START_HP = 2000
  HAND_SIZE = 5
  SINGLE_TARGET_EFFECTS = %w[enemy_monster self_monster].freeze

  # ---- 対戦開始 ----

  def self.start_for(user:, deck:, difficulty:)
    player_deck_card_ids = deck.cards.pluck(:id).shuffle
    player_hand_ids = player_deck_card_ids.shift(HAND_SIZE)

    cpu_user = User.find_by!(email: "cpu_bot@arcana.local")
    cpu_deck = cpu_user.decks.find_by!(name: "CPU_#{difficulty.upcase}_DECK")
    cpu_deck_ids = cpu_deck.cards.pluck(:id).shuffle
    cpu_hand_ids = cpu_deck_ids.shift(HAND_SIZE)

    first_turn = ["player", "cpu"].sample

    game = create!(
      user: user,
      difficulty: difficulty,
      status: "in_progress",
      state: {
        "turn_count" => 1,
        "player_hp" => PLAYER_START_HP,
        "cpu_hp" => CPU_START_HP,
        "player_deck" => player_deck_card_ids,
        "cpu_deck" => cpu_deck_ids,
        "player_hand" => player_hand_ids,
        "cpu_hand" => cpu_hand_ids,
        "player_field" => [],
        "cpu_field" => [],
        "pending_spell_id" => nil,
        "turn" => first_turn,
        "log" => [first_turn == "player" ? "あなたが先攻です！" : "相手が先攻です！"]
      }
    )

    game.cpu_take_turn if game.turn == "cpu"
    game
  end

  # ---- 読み取り用メソッド ----

  def player_hp
    state["player_hp"]
  end

  def cpu_hp
    state["cpu_hp"]
  end

  def turn
    state["turn"]
  end

  def log
    state["log"]
  end

  def player_hand_cards
    Card.where(id: state["player_hand"])
  end

  def player_field_monsters
    state["player_field"].map.with_index do |f, i|
      { index: i, card: Card.find(f["card_id"]), current_hp: f["current_hp"], attacked: f["attacked"] }
    end
  end

  def cpu_field_monsters
    state["cpu_field"].map.with_index do |f, i|
      { index: i, card: Card.find(f["card_id"]), current_hp: f["current_hp"], attacked: f["attacked"] }
    end
  end

  def add_log(message)
    state["log"] << message
    state["log"].shift if state["log"].size > 20
  end

  def finished?
    status == "finished"
  end

  # ---- プレイヤーの行動 ----

  def play_card(card_id)
    return unless turn == "player"
    card = Card.find(card_id)
    return unless state["player_hand"].include?(card_id)

    if card.monster?
      state["player_field"] << { "card_id" => card.id, "current_hp" => card.tier, "attacked" => false }
      add_log("#{card.name}を召喚した！")
      state["player_hand"].delete(card_id)
      save!
    else
      # 魔法は select_spell 経由で発動するのでここでは何もしない
      select_spell(card_id)
    end
  end

  def attack(attacker_index, target_index = nil)
    return unless turn == "player"
    return if state["turn_count"] == 1
    attacker = state["player_field"][attacker_index]
    return if attacker.nil? || attacker["attacked"]

    attacker_card = Card.find(attacker["card_id"])

    if state["cpu_field"].empty?
      state["cpu_hp"] -= attacker_card.attack
      add_log("#{attacker_card.name}が直接攻撃！ #{attacker_card.attack}ダメージ！")
    else
      target = state["cpu_field"][target_index]
      return if target.nil?
      target_card = Card.find(target["card_id"])

      damage = [attacker_card.attack - target_card.defense, 0].max
      target["current_hp"] -= damage
      add_log("#{attacker_card.name}が#{target_card.name}を攻撃！ #{damage}ダメージ！")

      if target["current_hp"] <= 0
        add_log("#{target_card.name}は破壊された！")
        state["cpu_field"].delete_at(target_index)
      end
    end

    attacker["attacked"] = true
    save!
    check_finish!
  end

  def end_turn
    return unless turn == "player"
    state["turn"] = "cpu"
    state["turn_count"] += 1
    save!
    draw_card("cpu")
    cpu_take_turn
  end

  # ---- 魔法カードの対象選択 ----

  def select_spell(card_id)
    return unless turn == "player"
    card = Card.find(card_id)
    return unless card.spell?
    return unless state["player_hand"].include?(card_id)

    if SINGLE_TARGET_EFFECTS.include?(card.effect_target)
      state["pending_spell_id"] = card_id
      save!
    else
      apply_spell(card, attacker: "player")
      add_log("#{card.name}を発動した！")
      state["player_hand"].delete(card_id)
      save!
      check_finish!
    end
  end

  def pending_spell
    return nil unless state["pending_spell_id"]
    Card.find(state["pending_spell_id"])
  end

  def confirm_spell_target(target_index)
    return unless state["pending_spell_id"]
    card_id = state["pending_spell_id"]
    card = Card.find(card_id)

    apply_spell(card, attacker: "player", target_index: target_index)
    add_log("#{card.name}を発動した！")

    state["player_hand"].delete(card_id)
    state["pending_spell_id"] = nil
    save!
    check_finish!
  end

  def cancel_spell
    state["pending_spell_id"] = nil
    save!
  end

  # ---- CPUの行動（簡易AI） ----
  # start_for から呼べるように public のままにしておく

  def cpu_take_turn
    draw_card("cpu") unless state["turn_count"] == 1

    monster_id = state["cpu_hand"].find { |id| Card.find(id).monster? }
    if monster_id
      card = Card.find(monster_id)
      state["cpu_field"] << { "card_id" => card.id, "current_hp" => card.tier, "attacked" => false }
      state["cpu_hand"].delete(monster_id)
      add_log("相手が#{card.name}を召喚した！")
    end

    state["cpu_field"].each do |attacker|
      next if attacker["attacked"]
      attacker_card = Card.find(attacker["card_id"])

      if state["player_field"].empty?
        state["player_hp"] -= attacker_card.attack
        add_log("相手の#{attacker_card.name}が直接攻撃！ #{attacker_card.attack}ダメージ！")
      else
        target = state["player_field"].first
        target_card = Card.find(target["card_id"])
        damage = [attacker_card.attack - target_card.defense, 0].max
        target["current_hp"] -= damage
        add_log("相手の#{attacker_card.name}が#{target_card.name}を攻撃！ #{damage}ダメージ！")
        if target["current_hp"] <= 0
          add_log("#{target_card.name}は破壊された！")
          state["player_field"].shift
        end
      end
      attacker["attacked"] = true
    end

    state["player_field"].each { |f| f["attacked"] = false }
    state["cpu_field"].each { |f| f["attacked"] = false }
    state["turn_count"] += 1
    state["turn"] = "player"
    draw_card("player")
    save!
    check_finish!
  end

  private

  def apply_spell(card, attacker:, target_index: nil)
    case card.effect_target
    when "enemy_monster"
      field = attacker == "player" ? "cpu_field" : "player_field"
      target = state[field][target_index]
      if target
        target_card = Card.find(target["card_id"])
        if card.effect_action == "destroy"
          add_log("#{target_card.name}は破壊された！")
          state[field].delete_at(target_index)
        elsif card.effect_action == "damage"
          target["current_hp"] -= card.effect_value
          if target["current_hp"] <= 0
            add_log("#{target_card.name}は破壊された！")
            state[field].delete_at(target_index)
          end
        end
      end
    when "self_monster"
      field = attacker == "player" ? "player_field" : "cpu_field"
      target = state[field][target_index]
      if target
        target_card = Card.find(target["card_id"])
        case card.effect_action
        when "heal"
          target["current_hp"] += card.effect_value
        when "atk_up", "atk_down"
          # 簡易実装：永続強化は今後拡張
        end
      end
    when "enemy_all_monster"
      field = attacker == "player" ? "cpu_field" : "player_field"
      state[field].each { |t| t["current_hp"] -= card.effect_value.to_i }
      state[field].reject! { |t| t["current_hp"] <= 0 }
    when "enemy_player"
      hp_key = attacker == "player" ? "cpu_hp" : "player_hp"
      state[hp_key] -= card.effect_value
    when "self_player"
      hp_key = attacker == "player" ? "player_hp" : "cpu_hp"
      state[hp_key] += card.effect_value
    end
  end

  def check_finish!
    if state["cpu_hp"] <= 0
      self.status = "finished"
      add_log("勝利！")
      save!
    elsif state["player_hp"] <= 0
      self.status = "finished"
      add_log("敗北…")
      save!
    end
  end

  def draw_card(side)
    deck_key = "#{side}_deck"
    hand_key = "#{side}_hand"
    return if state[deck_key].empty?

    drawn_id = state[deck_key].shift
    state[hand_key] << drawn_id
    card = Card.find(drawn_id)
    add_log("#{side == 'player' ? 'あなた' : '相手'}は#{card.name}をドローした")
  end
end
