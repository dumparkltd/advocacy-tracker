# frozen_string_literal: true

class RecommendationsController < ApplicationController
  # GET /recommendations
  def index
    @recommendations = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @recommendations

    render json: serialize(@recommendations)
  end

  # GET /recommendations/1
  def show
    render json: serialize(@recommendation)
  end

  # POST /recommendations
  def create
    @recommendation = Recommendation.new
    @recommendation.assign_attributes(permitted_attributes(@recommendation))
    authorize @recommendation

    if @recommendation.save
      render json: serialize(@recommendation), status: :created, location: @recommendation
    else
      render json: @recommendation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recommendations/1
  def update
    if params[:recommendation][:updated_at] && DateTime.parse(params[:recommendation][:updated_at]).to_i != @recommendation.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @recommendation.update!(permitted_attributes(@recommendation))
      render json: serialize(@recommendation)
    end
  end

  # DELETE /recommendations/1
  def destroy
    @recommendation.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def authorize!
    @recommendation = policy_scope(base_object)&.find(params[:id]) if params[:id]

    authorize @recommendation || base_object
  end

  def base_object
    if params[:category_id]
      Category.find(params[:category_id]).recommendations
    elsif params[:measure_id]
      Measure.find(params[:measure_id]).recommendations
    else
      Recommendation
    end
  end

  def serialize(target, serializer: RecommendationSerializer)
    super
  end
end
