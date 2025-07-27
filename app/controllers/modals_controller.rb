class ModalsController < ApplicationController
  before_action :set_modal, only: %i[ show edit update destroy ]

  # GET /modals
  def index
    @modals = Modal.all
  end

  # GET /modals/1
  def show
  end

  # GET /modals/new
  def new
    @modal = Modal.new
  end

  # GET /modals/1/edit
  def edit
  end

  # POST /modals
  def create
    @modal = Modal.new(modal_params)

    if @modal.save
      redirect_to @modal, notice: "Modal was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /modals/1
  def update
    if @modal.update(modal_params)
      redirect_to @modal, notice: "Modal was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /modals/1
  def destroy
    @modal.destroy!
    redirect_to modals_url, notice: "Modal was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_modal
      @modal = Modal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def modal_params
      params.require(:modal).permit(:nome)
    end
end
