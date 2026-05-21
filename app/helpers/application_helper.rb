module ApplicationHelper
  STATUS_COLORS = {
    "active"    => "bg-emerald-100 text-emerald-700",
    "paid"      => "bg-emerald-100 text-emerald-700",
    "captured"  => "bg-emerald-100 text-emerald-700",
    "placed"    => "bg-blue-100 text-blue-700",
    "customer"  => "bg-sky-100 text-sky-700",
    "draft"     => "bg-slate-100 text-slate-600",
    "cart"      => "bg-slate-100 text-slate-600",
    "pending"   => "bg-amber-100 text-amber-700",
    "archived"  => "bg-amber-100 text-amber-700",
    "cancelled" => "bg-red-100 text-red-700",
    "failed"    => "bg-red-100 text-red-700",
    "suspended" => "bg-red-100 text-red-700",
    "refunded"  => "bg-purple-100 text-purple-700",
    "admin"     => "bg-violet-100 text-violet-700"
  }.freeze

  def status_badge(value, label = nil)
    label ||= value.to_s.humanize
    css = STATUS_COLORS.fetch(value.to_s, "bg-slate-100 text-slate-600")
    content_tag(:span, label,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
  end

  def nav_link(label, path, icon)
    active = request.path == path || request.path.start_with?("#{path}/")
    base  = "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
    state = active ? "bg-indigo-600 text-white" : "text-slate-300 hover:bg-slate-800 hover:text-white"
    link_to(path, class: "#{base} #{state}") do
      safe_join([
        content_tag(:span, icon, class: "w-5 text-center leading-none"),
        content_tag(:span, label)
      ])
    end
  end
end
