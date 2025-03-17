class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:edit, :update]
  before_action :authorize_player, only: [:edit, :update]

  def index
    @matches = Match.where("player1_id = ? OR player2_id = ?", current_user.id, current_user.id).order(match_date: :asc)
  end

  def new
    @match = Match.new
    @opponents = User.where.not(id: current_user.id)
  end

  def create
    @match = Match.new(match_params)
    # Always set player1 to current user
    @match.player1 = current_user
    raise
    if @match.save
      # Optionally set winner if scores exist
      if @match.player1_score && @match.player2_score
        @match.update!(
          winner_id: @match.player1_score > @match.player2_score ? @match.player1_id : @match.player2_id
        )
      end

      redirect_to social_leaderboards_path, notice: "Social match created!"
      # Or wherever you want to redirect
    else
      # Rerender the form if validation errors
      @opponents = User.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
    end
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
    params.require(:match).permit(:player2_id, :player1_score, :player2_score, :match_date)
  end

  def determine_winner
    if @match.player1_score && @match.player2_score
      winner = @match.player1_score > @match.player2_score ? @match.player1 : @match.player2
      @match.update!(winner: winner)
    end
  end
end
