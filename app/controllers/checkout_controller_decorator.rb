CheckoutController.class_eval do
  def update_registration
    # hack - temporarily change the state to something other than cart so we can validate the order email address
    current_order.state = "address"
    if current_order.update_attributes(params[:order])
      # if all products are downloadables - set state as payment
      if current_order.all_downloadable?
        current_order.set_address
        redirect_to '/checkout/payment'
      else
        redirect_to checkout_path
      end
    else
      @user = User.new
      render 'registration'
    end
  end
end
