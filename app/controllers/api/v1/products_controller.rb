class Api::V1::ProductsController < ApplicationController
  before_action :check_login, only: %i[create]
  before_action :set_product, only: %i[show update destroy]
  before_action :check_owner, only: %i[update destroy]

  def show
    options = { include: [:user] }
    render json: ProductSerializer.new(@product, options).serializable_hash
  end

  def index
    current_page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i
    @pagy, @products = pagy(Product.search(params), items: per_page, page: current_page)
    options = {
      links: {
        first: api_v1_products_path(page: 1),
        last: api_v1_products_path(page: @pagy.count),
        prev: api_v1_products_path(page: @pagy.prev),
        next: api_v1_products_path(page: @pagy.next)
      }
    }
    render json: ProductSerializer.new(@products, options).serializable_hash
  end

  def create
    product = current_user.products.build(product_params)
    if product.save
      render json: ProductSerializer.new(product).serializable_hash, status: :created
    else
      render json: { errors: product.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: ProductSerializer.new(@product).serializable_hash
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head 204
  end

  private

  def check_owner
    head :forbidden unless @product.user_id == current_user&.id
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :price, :published)
  end
end
