$ ->
  sd = $(".accordion")
  return if sd.length == 0

  $.each sd, (i, v) ->
    toggle = $(".toggle", v)
    area   = $(".area", v)

    (->
      visible = false
      toggle.on 'click', (e) ->
        e.preventDefault()
        visible = !visible
        toggle.text if visible then "HIDE" else "SHOW"
        if visible then area.slideDown('slow') else area.slideUp('slow')
    )()
