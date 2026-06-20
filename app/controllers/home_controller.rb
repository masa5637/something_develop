class HomeController < ApplicationController
  def index
    @cards = user_signed_in? ? current_user.cards : []
  end
end
