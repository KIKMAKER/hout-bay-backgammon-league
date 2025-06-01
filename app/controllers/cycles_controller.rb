class CyclesController < ApplicationController
  before_action :set_cycle, only: %i[ show edit update destroy ]

  # GET /cycles
  def index
    @cycles = Cycle.all
  end

  # GET /cycles/1
  def show
    
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cycle
      @cycle = Cycle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cycle_params
      params.require(:cycle).permit(:start_date, :end_date, :weeks, :group_id)
    end
end
