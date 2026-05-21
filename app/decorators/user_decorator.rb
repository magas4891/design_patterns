class UserDecorator < ApplicationDecorator
  def role_label
    { "customer" => "Customer", "admin" => "Admin" }.fetch(role, role.capitalize)
  end

  def status_label
    { "active" => "Active", "inactive" => "Inactive" }.fetch(status, status.capitalize)
  end
end
