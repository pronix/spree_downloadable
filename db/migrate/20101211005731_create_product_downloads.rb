class CreateProductDownloads < ActiveRecord::Migration
  def self.up
    create_table :product_downloads do |t|
      t.string :title
      t.string :description
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.boolean :enabled, :default => true
      t.integer :viewable_id
      t.string :viewable_type
      t.integer :position
      t.integer :product_id
      t.timestamps
    end
    add_index :product_downloads, :product_id
    add_index :product_downloads, :viewable_id

  create_table "product_links", :force => true do |t|
    t.integer :product_id
    t.integer :order_id
    t.integer  "user_id"
    t.integer  "product_download_id",                         :null => false
    t.string   "link_file",                            :null => false
    t.string   "file_name",                            :null => false
    t.string   "file_path",                            :null => false
    t.string   "file_size",                            :null => false
    t.string   "content_type",                         :null => false
    t.integer  "current_count_streams", :default => 0
    t.datetime "expire",                               :null => false
    t.string   "status",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bytes_sent"
    t.integer  "concurenc_download"
  end

  add_index "product_links", ["link_file"], :name => "index_file_links_on_link_file", :unique => true
  add_index :product_links, :product_id
  add_index :product_links, :order_id
  add_index :product_links, :product_download_id

  # shipping_method  for download
  sh = ShippingMethod.create(:zone_id => 2 , :name => 'Download')
  calc = Calculator::FlatRate.create(:calculable_type => 'ShippingMethod', :calculable_id => '1000')
  sh.calculator = calc
  sh.save!
  add_index :shipping_methods, :name
  end

  def self.down
    drop_table :product_downloads
    drop_table :product_links
  end
end
