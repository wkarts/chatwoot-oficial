class Api::V1::Accounts::CategoriesController < Api::V1::Accounts::BaseController
  before_action :portal
  before_action :fetch_category, except: [:index, :create]

  def index
    @categories = @portal.categories.search(params)
  end

  def create
    @category = @portal.categories.create!(category_params)
    @category.linked_categories << link_categories
    render json: { error: @category.errors.messages }, status: :unprocessable_entity and return unless @category.valid?

    @category.save!
  end

  def show; end

  def update
    @category.update!(category_params)
    @category.linked_categories = link_categories if link_categories.any?
    render json: { error: @category.errors.messages }, status: :unprocessable_entity and return unless @category.valid?

    @category.save!
  end

  def destroy
    @category.destroy!
    head :ok
  end

  private

  def fetch_category
    @category = @portal.categories.find(params[:id])
  end

  def portal
    @portal ||= Current.account.portals.find_by(slug: params[:portal_id])
  end

  def link_categories
    @portal.categories.where(id: params[:category][:linked_category_ids])
  end

  def category_params
    params.require(:category).permit(
      :name, :description, :position, :slug, :locale, :parent_category_id
    )
  end
end
