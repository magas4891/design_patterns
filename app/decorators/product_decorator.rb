class ProductDecorator < ApplicationDecorator
  def formatted_price
    format("$%.2f", price_cents / 100.0)
  end

  def status_label
    { "draft" => "Draft", "active" => "Active", "archived" => "Archived" }.fetch(status, status.capitalize)
  end

  def category_name
    category.name
  end
end
