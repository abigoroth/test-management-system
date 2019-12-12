class SpecsController < ApplicationController
  before_action :set_spec, only: [:show, :edit, :update, :destroy]
  before_action :set_feature
  before_action :set_project
  # GET /specs
  # GET /specs.json
  def index
    @specs = Spec.all
  end

  # GET /specs/1
  # GET /specs/1.json
  def show
  end

  # GET /specs/new
  def new
    @spec = Spec.new
  end

  # GET /specs/1/edit
  def edit
  end

  # POST /specs
  # POST /specs.json
  def create
    @spec = @feature.specs.new(spec_params)

    respond_to do |format|
      if @spec.save
        format.html { redirect_to [@project, @feature], notice: 'Spec was successfully created.' }
        format.json { render :show, status: :created, location: @spec }
      else
        format.html { render :new }
        format.json { render json: @spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /specs/1
  # PATCH/PUT /specs/1.json
  def update
    respond_to do |format|
      if @spec.update(spec_params)
        format.html { redirect_to [@project, @feature], notice: 'Spec was successfully updated.' }
        format.json { render :show, status: :ok, location: @spec }
      else
        format.html { render :edit }
        format.json { render json: @spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /specs/1
  # DELETE /specs/1.json
  def destroy
    @spec.destroy
    respond_to do |format|
      format.html { redirect_to [@project, @feature], notice: 'Spec was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_feature
      @feature = Feature.find(params[:feature_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_spec
      @spec = Spec.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def spec_params
      params.require(:spec).permit(:name, :step, :feature_id, :expected, :description)
    end
end
