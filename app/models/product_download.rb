class ProductDownload < ActiveRecord::Base
  belongs_to :viewable, :polymorphic => true
  belongs_to :product
  has_many :product_links
  acts_as_list :scope => :viewable
  has_attached_file :attachment,
                    :url => "/downloadable/:id/:secret/:basename.:extension",
                    :path => ":rails_root/public/downloadable/:id/:secret/:basename.:extension"
end
