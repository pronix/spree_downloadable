OrderMailer.class_eval do
  def deliver_downloadable_products(order,resend=false)
    @order = order
    puts @order.class
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} Download Order ##{@order.id}"
    mail(:to => @order.email,
         :subject => subject)
  end
end
