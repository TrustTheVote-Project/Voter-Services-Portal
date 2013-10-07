$ ->
  $(".mark-online").each (i, f) ->
    form = $(f)
    $("a.mark-submit", form).click (e) ->
      e.preventDefault()
      form.submit()
