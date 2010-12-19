Payment.class_eval do
# после завершения оплаты вызываем OrderMailer.deliver_downloadable_products(self).deliver
  fsm = self.state_machines[:state]
  fsm.after_transition :to => 'completed', :do => lambda {|payment| OrderMailer.deliver_downloadable_products(payment.order).deliver }
end
