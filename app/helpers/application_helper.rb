module ApplicationHelper
  # === VALORES SEGUROS ============================================
  def safe_val(value, placeholder: "—")
    s = value.to_s.strip
    s.present? ? sanitize(s) : placeholder
  end

  # === PAGINAÇÃO SIMPLES =========================================
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
              class: "px-4 py-2 rounded-lg border bg-white dark:bg-gray-800 hover:bg-gray-50"
    else
      content_tag :span, "◀︎ Anterior",
                  class: "px-4 py-2 rounded-lg border opacity-40 cursor-not-allowed",
                  aria: { disabled: true }
    end

    right_btn = if has_next
      link_to "Próxima ▶︎",
              url_for(base_params.merge(page: next_page, per: per)),
              class: "px-4 py-2 rounded-lg border bg-white dark:bg-gray-800 hover:bg-gray-50"
    else
      content_tag :span, "Próxima ▶︎",
                  class: "px-4 py-2 rounded-lg border opacity-40 cursor-not-allowed",
                  aria: { disabled: true }
    end

    middle = content_tag :span,
                         "Página #{page} de #{total_pages} (#{total} registros)",
                         class: "text-sm text-gray-600 dark:text-gray-400"

    content_tag :nav, class: "mt-6 flex flex-col md:flex-row gap-3 items-center justify-between" do
      safe_join([left_btn, middle, right_btn])
    end
  rescue => e
    Rails.logger.error("[simple_pagination] #{e.class}: #{e.message}")
    "".html_safe
  end

  # === NAVBAR LINKS ==============================================
  def active_link_class(path, active_class: "border-b-2 border-yellow-300 pb-1", inactive_class: "")
    current_page?(path) ? active_class : inactive_class
  end

  def nav_link_to(name, path, extra_class: "")
    link_to name, path,
      class: "text-white hover:text-blue-200 transition duration-300 #{active_link_class(path)} #{extra_class}",
      aria: { current: current_page?(path) ? "page" : nil }
  end

  # === LINKS CONDICIONAIS ========================================
  def conditional_nav_link(name, path, condition)
    return unless condition
    nav_link_to(name, path)
  end

  def admin_nav_link
    conditional_nav_link("Administração", admin_root_path, defined?(current_admin_user) && current_admin_user.present?)
  end

  def chat_nav_link
    conditional_nav_link("Chat", chats_path, defined?(current_cliente) && current_cliente.present?)
  end

  def pagamentos_nav_link
    conditional_nav_link("Pagamentos", pagamentos_path, respond_to?(:pagamentos_path))
  end

  def fidelidade_nav_link
    conditional_nav_link("Fidelidade", fidelidade_path, respond_to?(:fidelidade_path))
  end
end
