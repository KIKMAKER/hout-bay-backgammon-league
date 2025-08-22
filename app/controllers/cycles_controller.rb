class CyclesController < ApplicationController
  before_action :set_cycle, only: %i[ show edit update destroy matches]

  # GET /cycles
  def index
    @cycles = Cycle.all
  end

  # GET /cycles/1
  def show
    @round = Round.find(params[:round_id])
    @matches = cycle_matches(@cycle)

    @players  = (@matches.map(&:player1) + @matches.map(&:player2)).uniq
    @rankings = calculate_rankings(@players, @cycle, @matches)
  end

  # GET /cycles/new
  def new
    @cycle = Cycle.new
  end

  # GET /cycles/1/edit
  def edit
  end

  # POST /cycles
  def create
    @cycle = Cycle.new(cycle_params)

    if @cycle.save
      redirect_to @cycle, notice: "Cycle was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cycles/1
  def update
    if @cycle.update(cycle_params)
      redirect_to @cycle, notice: "Cycle was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /cycles/1
  def destroy
    @cycle.destroy!
    redirect_to cycles_url, notice: "Cycle was successfully destroyed.", status: :see_other
  end

  def matches
    @matches = @cycle.matches
    @round = @cycle.round
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cycle
    @cycle = Cycle.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def cycle_params
    params.require(:cycle).permit(:start_date, :end_date, :weeks, :group_id)
  end

  def calculate_rankings(players, cycle, matches)
    completed = matches.select { |m| m.winner_id.present? || (m.player1_score && m.player2_score) }

    players
      .map do |player|
        wins   = completed.count { |m| m.winner_id == player.id }
        played = completed.count { |m| m.player1_id == player.id || m.player2_id == player.id }

        {
          player: player,
          wins: wins,
          matches_played: played
        }
      end
      # pass completed to H2H so ties/order use only real results
      .sort_by { |h| [-h[:wins], -head_to_head_wins(h[:player], players, completed)] }
  end

  def head_to_head_wins(player, players, matches)
    players.sum do |opponent|
      next 0 if opponent == player
      matches.count do |m|
        m.winner_id == player.id &&
          ((m.player1_id == opponent.id && m.player2_id == player.id) ||
           (m.player2_id == opponent.id && m.player1_id == player.id))
      end
    end
  end

  def cycle_matches(cycle)
    Match.where(cycle_id: cycle.id)
        #  .where.not(winner_id: nil)
         .includes(:player1, :player2, :winner)
  end
end
