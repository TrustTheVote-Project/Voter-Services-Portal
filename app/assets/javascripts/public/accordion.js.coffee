$ ->
  sd = $(".accordion")
  return if sd.length == 0

  $.each sd, (i, v) ->
    toggle = $(".toggle", v)
    area   = $(".area", v)

    (->
      visible = false
      toggle.click ->
        visible = !visible
        toggle.text if visible then "HIDE" else "SHOW"
        if visible then area.show() else area.hide()
    )()
