module UiHelper
  def safe_val(value, dash: "—")
    v = (value.respond_to?(:presence) ? value.presence : value)
    v.nil? || (v.respond_to?(:empty?) && v.empty?) ? dash : v
  end

  def money(num)
    return "—" if num.nil?
    number_to_currency(num, unit: "R$ ", separator: ",", delimiter: ".", format: "%u%n")
  end

  def badge_status(status)
    label = status.to_s.strip
    klass = case label.downcase
            when "pendente", "pending"     then "bg-yellow-100 text-yellow-800"
            when "ativo", "active", "ok"  then "bg-green-100 text-green-800"
            when "cancelado", "canceled"    then "bg-red-100 text-red-800"
            else "bg-gray-100 text-gray-800"
            end
    content_tag(:span, (label.present? ? label.titleize : "—"), class: "px-2 py-0.5 rounded text-sm #{klass}")
  end

  # paginação simples: Previous/Next por querystring
  def simple_pagination(base_path, pager)
    content_tag :div, class: "flex items-center gap-2 mt-4" do
      prev = link_to("Anterior", url_for(base_path.merge(page: pager[:page] - 1, per: pager[:per])),
                     class: "px-3 py-1 rounded border", disabled: pager[:page] <= 1)
      nxt  = link_to("Próxima",  url_for(base_path.merge(page: pager[:page] + 1, per: pager[:per])),
                     class: "px-3 py-1 rounded border", disabled: !pager[:has_next])
      prev.concat(nxt)
    end
  end
end