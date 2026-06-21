class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game, except: [:create]

  def create
    deck = current_user.decks.find(params[:deck_id])
    difficulty = params[:difficulty]
    @game = Game.start_for(user: current_user, deck: deck, difficulty: difficulty)
    redirect_to game_path(@game)
  end

  def show
  end

  def play_card
    @game.play_card(params[:card_id].to_i)
    redirect_to game_path(@game)
  end

  def attack
    @game.attack(params[:attacker_index].to_i, params[:target_index].presence&.to_i)
    redirect_to game_path(@game)
  end

  def end_turn
    @game.end_turn
    redirect_to game_path(@game)
  end

  private

  def set_game
    @game = current_user.games.find(params[:id])
  end
end