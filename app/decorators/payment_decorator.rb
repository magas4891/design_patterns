class PaymentDecorator < ApplicationDecorator
  def formatted_amount
    format("$%.2f", amount_cents / 100.0)
  end

  def formatted_paid_at
    paid_at&.strftime("%b %d, %Y %H:%M") || "—"
  end

  def status_label
    { "pending" => "Pending", "captured" => "Captured", "failed" => "Failed", "refunded" => "Refunded" }.fetch(status, status.capitalize)
  end
end
