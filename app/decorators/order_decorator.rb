class OrderDecorator < ApplicationDecorator
  def formatted_total
    format("$%.2f", total_cents / 100.0)
  end

  def formatted_placed_at
    placed_at&.strftime("%b %d, %Y %H:%M") || "—"
  end

  def status_label
    { "cart" => "Cart", "placed" => "Placed", "paid" => "Paid", "cancelled" => "Cancelled" }.fetch(status, status.capitalize)
  end

  def user_name
    user.name
  end
end
