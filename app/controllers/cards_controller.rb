class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:edit, :update, :destroy]

  def index
    @cards = current_user.cards
  end

  def new
    @card = current_user.cards.new
  end

  def create
    @card = current_user.cards.new(card_params)
    if @card.save
      redirect_to cards_path, notice: "カードを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      redirect_to cards_path, notice: "カードを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to cards_path, notice: "カードを削除しました"
  end

  def set_card
    @card = current_user.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:name, :card_type, :image, :tier, :attack, :defense, :effect_target, :effect_action, :effect_value)
  end
end
