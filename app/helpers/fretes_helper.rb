module FretesHelper
  def status_badge(frete)
    case frete.status
    when "em_andamento"
      content_tag(:span, "Em andamento", class: "px-3 py-1 rounded-full bg-yellow-200 text-yellow-800 text-sm font-semibold")
    when "finalizado"
      content_tag(:span, "Finalizado", class: "px-3 py-1 rounded-full bg-green-200 text-green-800 text-sm font-semibold")
    when "cancelado"
      content_tag(:span, "Cancelado", class: "px-3 py-1 rounded-full bg-red-200 text-red-800 text-sm font-semibold")
    else
      content_tag(:span, frete.status, class: "px-3 py-1 rounded-full bg-gray-200 text-gray-800 text-sm font-semibold")
    end
  end
end
