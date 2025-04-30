class OrderMailer < ApplicationMailer
  def received(order)
    @order = order
    @line_items = @order.line_items.includes(meal: { image_attachment: :blob })

    @line_items.each_with_index do |line_item, item_index|
      image = line_item.meal.image.open(&:read)
      attachments.inline["line_item_#{item_index}"] = {
        data: image,
        mime_type: line_item.meal.image.content_type
      }
    end

    mail(to: @order.user.email)
  end
end
