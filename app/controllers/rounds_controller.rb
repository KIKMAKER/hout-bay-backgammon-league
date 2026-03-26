class RoundsController < ApplicationController
  def index
    @rounds = Round.order(start_date: :asc)
  end

  def show
    @round  = Round.find(params[:id])
    @cycles = @round.cycles.includes(:group).order("groups.title")
  end

   def new
    @round = Round.new(
      start_date: Date.today,
      end_date:   Date.today + 9.weeks
    )
    # Set default values for the form (not persisted to Round)
    @round.weeks = 9
    @round.catch_up_weeks = 3
  end

  def create
    # Extract weeks and catch_up_weeks from params
    weeks = params[:round][:weeks].to_i
    catch_up_weeks = params[:round][:catch_up_weeks].to_i

    @round = Round.new(round_params.except(:weeks, :catch_up_weeks))

    # Build one cycle per group with the same characteristics
    Group.order(:title).find_each do |group|
      @round.cycles.build(
        group:          group,
        weeks:          weeks,
        catch_up_weeks: catch_up_weeks,
        start_date:     @round.start_date,
        end_date:       @round.end_date
      )
    end

    begin
      ActiveRecord::Base.transaction do
        # guard_no_overlapping_cycles!  # optional
        @round.save!

        @round.cycles.includes(group: :users).each do |cycle|
          generate_matches_for_cycle(cycle)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      return render :new, status: :unprocessable_entity
    rescue => e
      flash.now[:alert] = "Could not start round: #{e.message}"
      return render :new, status: :unprocessable_entity
    end

    # SUCCESS PATH — do exactly one redirect, then STOP.
    redirect_to rounds_path, notice: "New round started." and return
  end

  private

  def round_params
    params.require(:round).permit(:start_date, :end_date, :weeks, :catch_up_weeks)
  end

  def require_admin!
    head :forbidden unless current_user&.admin?
  end

  # Simple safety: block a new round if any cycle is active today
  def guard_no_overlapping_cycles!
    if Cycle.where("start_date <= ? AND end_date >= ?", Date.today, Date.today).exists?
      raise "There is an active cycle already."
    end
  end

  # QUICK + MESSY: inline generator with weekly dates
  def generate_matches_for_cycle(cycle)
    players = cycle.group.users.order(:username).to_a
    return if players.size < 2

    pairs_by_week = round_robin_pairs(players)
    weeks_to_schedule = [pairs_by_week.size, cycle.weeks.to_i].min
    base_date = cycle.start_date

    weeks_to_schedule.times do |week_index|
      date = base_date + week_index.weeks
      pairs_by_week[week_index].each do |(p1, p2)|
        Match.create!(cycle: cycle, player1: p1, player2: p2, match_date: date)
      end
    end
  end

  # Circle method; inserts a bye if odd number of players
  def round_robin_pairs(players)
    ps = players.dup
    ps << nil if ps.size.odd?
    n = ps.size
    fixed = ps.first
    rot   = ps[1..-1]

    rounds = []
    (n - 1).times do
      arr = [fixed] + rot
      pairs = []
      (0...(n / 2)).each do |i|
        a = arr[i]
        b = arr[-(i + 1)]
        next if a.nil? || b.nil?
        pairs << [a, b]
      end
      rounds << pairs
      rot.rotate!(-1)
    end
    rounds
  end
end
