class OrderCheckoutValidatorService
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def process
    check_pickup_time_greater_than_current_time && check_pickup_time_for_location
  end

  private def check_pickup_time_greater_than_current_time
    return true if order.pickup_time.blank? || order.pickup_time >= Time.current

    order.errors.add(:pickup_time, I18n.t('models.order.validations.pickup_time.invalid'))
    false
  end

  private def check_pickup_time_for_location
    p order.pickup_time
    return true if order.pickup_time.blank? || (order.location.opening_time.to_fs(:time) <= order.pickup_time.to_fs(:time) && order.location.closing_time.to_fs(:time) >= order.pickup_time.to_fs(:time))

    order.errors.add(:pickup_time, I18n.t('models.order.validations.pickup_time.unavailable'))
    false
  end
end
