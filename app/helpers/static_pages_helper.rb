module StaticPagesHelper

  def render_static_page(page)
    content_tag(:div, [
      content_tag(:div, [
        content_tag(:div, nil, class: 'span16 external-page', 'data-external' => page).html_safe
      ].join.html_safe, class: 'row')
    ].join.html_safe, class: 'padded_page_span')
  end

end
