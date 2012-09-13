$ ->
  sd = $(".show-districts")
  return if sd.length == 0

  sd.click ->
    sd.hide()
    $(".districts").show()
