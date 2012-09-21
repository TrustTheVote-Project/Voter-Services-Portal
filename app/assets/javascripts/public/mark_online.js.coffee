$ ->
  $("#mark-online").click (e) ->
    e.preventDefault()
    $("form.mark-online").submit()
