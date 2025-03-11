class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:edit, :update]
  before_action :authorize_player, only: [:edit, :update]

  def index
    @matches = Match.where("player1_id = ? OR player2_id = ?", current_user.id, current_user.id).order(match_date: :asc)
  end

  def edit
  end

  def update
    if @match.update(match_params)
      determine_winner
      redirect_to matches_path, notice: "Match result submitted successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def authorize_player
    unless @match.player1 == current_user || @match.player2 == current_user
      redirect_to matches_path, alert: "You are not authorized to update this match."
    end
  end

  def match_params
    params.require(:match).permit(:player1_score, :player2_score)
  end

  def determine_winner
    if @match.player1_score && @match.player2_score
      winner = @match.player1_score > @match.player2_score ? @match.player1 : @match.player2
      @match.update!(winner: winner)
    end
  end
end
