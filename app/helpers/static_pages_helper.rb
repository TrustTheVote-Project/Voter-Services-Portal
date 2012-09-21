module StaticPagesHelper

  def render_static_page(page)
    content_tag(:iframe, nil, class: 'padded_page_span static', src: AppConfig['static_page_url_base'] + "#{page}.html").html_safe
  end

end
