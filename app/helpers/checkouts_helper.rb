module CheckoutsHelper
  def checkout_steps
    checkout_steps = %w{registration billing shipping shipping_method payment confirmation}
    checkout_steps.delete "registration" if current_user
    checkout_steps.delete "shipping" if only_downloadable
    checkout_steps.delete "shipping_method" if only_downloadable
    checkout_steps
  end

  # Checks if checkout cart has ONLY downloadable items
  # Used for shipping in helpers/checkouts_helper.rb
  def only_downloadable
    downloadable_count = 0
    @order.line_items.each do |item|
      if((!item.product.downloadables.empty?) || (!item.variant.downloadables.empty?))
        downloadable_count += 1
      end
    end
    @order.line_items.size == downloadable_count
  end

  def has_downloadable?
    @order.line_items.each do |item|
      return true if ((!item.product.downloadables.empty?) || (!item.variant.downloadables.empty?))
    end
  end

  def render_links(item,order_id)
    if !item.product.product_download.nil?
      return content_tag(:sub,t(:download) + ': ' + link_to("#{item.product.product_download.attachment_file_name}", "/product_downloads/#{generate_secret(item.product.id,order_id)}" ))
    elsif !item.variant.product_download.nil?
      return content_tag(:sub,link_to("#{item.variant.product_download.attachment_file_name}", "/product_downloads/#{generate_secret(item.product_id,order_id)}" ))
    end
  end

  def generate_secret(product_id, order_id)
    ProductLink.where(:product_id => product_id, :order_id => order_id).limit(1).first.link_file
  end
end
