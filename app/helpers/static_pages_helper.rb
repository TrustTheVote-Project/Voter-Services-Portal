module StaticPagesHelper

  def render_static_page(page)
    content_tag(:div, [
      content_tag(:div, [
        content_tag(:div, image_tag('spinner.gif', size: '36x39'), class: 'span16 external-page', 'data-external' => page).html_safe
      ].join.html_safe, class: 'row')
    ].join.html_safe, class: 'padded_page_span')
  end

  def render_static_section(name)
    content_tag(:div, image_tag('spinner.gif', size: '36x39'), class: 'external-page', 'data-external' => name).html_safe
  end

end
