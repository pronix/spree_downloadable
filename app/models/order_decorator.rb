fsm = Order.state_machines[:state]
fsm.before_transition :to => 'address', :do => :set_address, :if => :all_downloadable?
fsm.after_transition :to => 'complete', :do => :create_links_for_products
fsm.event("pay_for_download").transition(:to => 'payment', :from => ['address'])
Order.class_eval do
  has_many :product_links
   # проверки - все ли товары в заказе скачиваемые
   # FIXME правильнее переписать в один запрос
   def all_downloadable?
     !self.products.map(&:downloadable?).include?(nil)
   end

   # получаем все ссылки по заказу возвращает array c ссылками
   def all_links
     self.line_items.map do |item|
       if item.product.downloadable?
         { :name =>item.product.name, :link => ProductLink.where(:product_id => item.product.id, :order_id => self.id ).limit(1).first.link_file}
       end
     end
   end

   # назначаем адрес и метод доставки если все товары скачиваемые
   # если же есть физические - то стандартная процедура
   def set_address
     if self.state == 'address'
       self.shipping_method = ShippingMethod.find_by_name 'Download' #FIXME this shipment set in migration
       self.save!
       # работаем без адреса или берем существующий
       if self.user.ship_address.nil?
         # работаем без адреса
         self.use_billing = false
         self.pay_for_download!
       else
         # берем существующий
         self.ship_address = self.user.ship_address
       end
     end
   end

   # генерим ссылки на скачивание
   # и шлем на почту уведомление с ссылками для скачивания цифровых товаров
   def create_links_for_products
     self.products.each do |product|
       if product.downloadable?
         product.create_link(self.id)
       end
     end
   end
end
