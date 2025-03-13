# app/controllers/admin/cycles_controller.rb
module Admin
  class CyclesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_group, except: %i[show index]

    def index
      @cycles = Cycle.all.order(start_date: :desc)
    end

    def show
      @cycle = Cycle.find(params[:id])
      # Eager-load players to avoid N+1 queries
      @matches = @cycle.matches.includes(:player1, :player2, :winner)
    end

    def new
      @cycle = @group.cycles.new
    end

    def create
      @cycle = @group.cycles.new(cycle_params)
      @cycle.end_date = @cycle.start_date + @cycle.catch_up_weeks.weeks + @cycle.weeks.weeks
      if @cycle.save
        generate_matches_for_cycle(@cycle)
        redirect_to admin_cycle_path(@cycle), notice: "Cycle created and matches generated!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def cycle_params
      params.require(:cycle).permit(:start_date, :end_date, :weeks, :catch_up_weeks)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Unauthorized!" unless current_user.admin?
    end

    def build_round_robin_schedule(players)
      # If odd number of players, add a nil "bye"
      players << nil if players.size.odd?
      n = players.size
      # Number of rounds needed so everyone meets once
      rounds = n - 1

      # Separate out first player so we can rotate the rest around them
      fixed = players.first
      others = players[1..]

      schedule = []
      rounds.times do
        # Pair up 'fixed' with the first of 'others'
        current_round = []
        current_round << [fixed, others.first] if fixed || others.first

        # Then pair up the rest in pairs from outside in
        left = 1
        right = others.size - 1

        while left < right
          current_round << [others[left], others[right]]
          left += 1
          right -= 1
        end

        schedule << current_round

        # Rotate the array for the next round
        # Move the first 'others' element to the end
        others = others.rotate(-1)
      end

      schedule
    end

    def generate_matches_for_cycle(cycle)
      players = cycle.group.users.to_a
      schedule = build_round_robin_schedule(players)

      schedule.each_with_index do |round, i|
        # Each round is i weeks after the start date (all Tuesdays)
        round_date = cycle.start_date + i.weeks

        round.each do |(player1, player2)|
          # Skip a "bye" match if odd number of players
          next if player1.nil? || player2.nil?

          Match.create!(
            player1: player1,
            player2: player2,
            cycle: cycle,
            match_date: round_date
          )
        end
      end
    end
  end

end
