$ ->
  $("div[data-external]").each (i, e) ->
    el  = $(e)
    id = el.attr('data-external')

    # Start loading the page
    $.get("/p/" + id, (d, s, x) ->
      el.hide().html(d).fadeIn('slow')
    )
