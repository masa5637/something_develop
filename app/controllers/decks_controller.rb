# app/controllers/decks_controller.rb
class DecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck, only: [:edit, :update, :destroy, :add_card, :remove_card]

  def index
    @decks = current_user.decks
  end

  def new
    @deck = current_user.decks.new
  end

  def create
    @deck = current_user.decks.new(deck_params)
    if @deck.save
      redirect_to edit_deck_path(@deck), notice: "デッキを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @my_cards = current_user.cards
    @deck_card_ids = @deck.card_ids
  end

  def update
    if @deck.update(deck_params)
      redirect_to decks_path, notice: "デッキ名を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deck.destroy
    redirect_to decks_path, notice: "デッキを削除しました"
  end

  def add_card
    card = current_user.cards.find(params[:card_id])

    if @deck.cards.include?(card)
      redirect_to edit_deck_path(@deck), alert: "すでにデッキに入っています" and return
    end
    if @deck.cards.count >= 20
      redirect_to edit_deck_path(@deck), alert: "デッキは20枚までです" and return
    end
    if card.monster? && card.tier == 300 && @deck.cards.where(card_type: "monster", tier: 300).count >= 2
      redirect_to edit_deck_path(@deck), alert: "300族モンスターは2枚までです" and return
    end

    @deck.cards << card
    redirect_to edit_deck_path(@deck), notice: "#{card.name}を追加しました"
  end

  def remove_card
    card = current_user.cards.find(params[:card_id])
    @deck.cards.delete(card)
    redirect_to edit_deck_path(@deck)
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:id])
  end

  def deck_params
    params.require(:deck).permit(:name)
  end
end