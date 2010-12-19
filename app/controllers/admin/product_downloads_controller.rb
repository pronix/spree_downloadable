class Admin::ProductDownloadsController < Admin::BaseController
  resource_controller
  index.before do
    @product = Product.find_by_permalink(params[:product_id])
  end

  create.before do
    product = Product.find_by_permalink(params[:product_id])
    product.product_download.try(:destroy)
    object.product_id = product.id
    object.save!
  end
  create.wants.html { redirect_to admin_products_url(parent_url_options) }
end
