$ ->
  popovers = $("a[data-toggle='popover']")
  popovers.popover()
  popovers.on 'click', (e) -> e.preventDefault()
