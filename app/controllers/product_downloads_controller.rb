class ProductDownloadsController < Spree::BaseController
  # require_user is a method in Application.rb
  # disabled to enable downloads for non-members
  # before_filter :require_user, :only => :show

  ssl_required :show

  def show
    prodlink = ProductLink.find_by_file_link(params[:s])
    unless params[:id].to_i == prodlink.product.id
      item = LineItem.find(params[:id])
      flash[:error] = t(:unauthorized_access)
      redirect_to order_url(item.order)
    else
      filepath = ""
      if !item.product.downloadables.empty?
        filepath = item.product.downloadables.first.attachment.path
      elsif !item.variant.downloadables.empty?
        filepath = item.variant.downloadables.first.attachment.path
      end
      # In pratical use, enabled X-sendfile in your server flavor ie. Apache, lighty, etc..
      # DON'T use mongrel/webrick, since files are static. Resources will be wasted since it'll go thru the rails stack to
      # fetch the file. Uncomment the line below.
      send_file filepath #, :x_sendfile => true
    end
  end
end
