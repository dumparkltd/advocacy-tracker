class CategoriesController < ApplicationController
  # GET /categories
  def index
    @categories = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @categories

    render json: serialize(@categories)
  end

  # GET /categories/1
  def show
    render json: serialize(@category)
  end

  # POST /categories
  def create
    @category = Category.new
    @category.assign_attributes(permitted_attributes(@category))
    authorize @category

    if @category.save
      render json: serialize(@category), status: :created, location: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if params[:category][:updated_at] && DateTime.parse(params[:category][:updated_at]).to_i != @category.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end

    if @category.update!(permitted_attributes(@category))
      render json: serialize(@category)
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def authorize!
    @category = policy_scope(base_object)&.find(params[:id]) if params[:id]

    authorize @category || base_object
  end

  def base_object
    Category
  end

  def serialize(target, serializer: CategorySerializer)
    super
  end
end
