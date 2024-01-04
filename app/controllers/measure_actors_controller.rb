class MeasureActorsController < ApplicationController
  # GET /measure_actors/:id
  def show
    @measure_actor = policy_scope(base_object).find(params[:id])
    authorize @measure_actor
    render json: serialize(@measure_actor)
  end

  # GET /measure_actors
  def index
    @measure_actors = policy_scope(base_object).all
    authorize @measure_actors
    render json: serialize(@measure_actors)
  end

  # POST /measure_actors
  def create
    @measure_actor = MeasureActor.new
    @measure_actor.assign_attributes(permitted_attributes(@measure_actor))
    authorize @measure_actor

    if @measure_actor.save
      render json: serialize(@measure_actor), status: :created, location: @measure_actor
    else
      render json: @measure_actor.errors, status: :unprocessable_entity
    end
  end

  # DELETE /measure_actors/1
  def destroy
    @measure_actor.destroy
  end

  # PATCH/PUT /actor_categories/1
  def update
    if @measure_actor.update!(permitted_attributes(@measure_actor))
      render json: serialize(@measure_actor)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def authorize!
    @measure_actor = policy_scope(base_object)&.find(params[:id]) if params[:id]

    authorize @measure_actor || base_object
  end

  def base_object
    MeasureActor
  end

  def serialize(target, serializer: MeasureActorSerializer)
    super
  end
end
