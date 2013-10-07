$ ->
  $("a.mark-submit").click (e) ->
    e.preventDefault()
    $("form.mark-online").submit()
