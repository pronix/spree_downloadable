require 'md5'
Product.class_eval do
  has_one :product_download
  has_many :product_links
  def downloadable?
    !self.product_download.nil?
  end
  def create_link(order_id)
    self.product_links.create!(:order_id => order_id, :product_id => self.id, :product_download_id => self.product_download.id)
  end
  private
  def gen_secret
    MD5.new(rand.to_s).to_s
  end
end
