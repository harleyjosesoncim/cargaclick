# app/helpers/application_helper.rb
module ApplicationHelper
  # Exibe string sanitizada ou "—"
  def safe_val(value, placeholder: "—")
    s = value.to_s.strip
    s.present? ? sanitize(s) : placeholder
  end

  # Paginação simples usando o hash @pager do controller
  # Exemplo de uso na view:
  #   simple_pagination({ controller: :clientes, action: :index, q: @q }, @pager)
  def simple_pagination(base_params, pager)
    return "".html_safe if pager.blank?

    page        = pager[:page].to_i
    per         = pager[:per].to_i
    total       = pager[:total].to_i
    total_pages = (pager[:total_pages].presence || (total.to_f / [per, 1].max).ceil).to_i
    has_next    = pager.key?(:has_next) ? !!pager[:has_next] : (page < total_pages)

    return "".html_safe if total_pages <= 1

    prev_page = page - 1
    next_page = page + 1

    left_btn = if page > 1
      link_to "◀︎ Anterior",
        url_for(base_params.merge(page: prev_page, per: per)),
        class: "px-4 py-2 rounded-lg border hover:bg-gray-50"
    else
      content_tag :span, "◀︎ Anterior",
        class: "px-4 py-2 rounded-lg border opacity-40 cursor-not-allowed",
        aria: { disabled: true }
    end

    right_btn = if has_next
      link_to "Próxima ▶︎",
        url_for(base_params.merge(page: next_page, per: per)),
        class: "px-4 py-2 rounded-lg border hover:bg-gray-50"
    else
      content_tag :span, "Próxima ▶︎",
        class: "px-4 py-2 rounded-lg border opacity-40 cursor-not-allowed",
        aria: { disabled: true }
    end

    middle = content_tag :span,
      "Página #{page} de #{total_pages} (#{total} registros)",
      class: "text-sm text-gray-600"

    content_tag :nav, class: "mt-6 flex items-center justify-between" do
      safe_join([left_btn, middle, right_btn])
    end
  rescue => e
    Rails.logger.error("[simple_pagination] #{e.class}: #{e.message}")
    "".html_safe
  end
end
