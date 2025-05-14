class OrderCompletionMailWorker
  include Sidekiq::Job

  def perform(order_id)
    return unless order = Order.with_complete_state.find_by(id: order_id)

    OrderMailer.received(order).deliver
  end
end
