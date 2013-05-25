filter = (e) ->
  # backspace, tab, enter, arrows, digits
  allowed = [ 8, 9, 13, 37, 38, 39, 40, 58 ]
  kc = e.keyCode
  e.preventDefault() if !((kc >= 48 && kc <= 57) || (kc >= 96 && kc <= 105) ||  allowed.indexOf(kc) != -1)

  # delete extra character if is standing on dash
  if e.keyCode == 8
    input = this.value
    len   = input.length
    if len > 0 && input[input.length - 1] == '-'
      this.value = input.substring(0, input.length - 1)

maskInput = (input, textbox, locs, delimiter) ->
  input = input.replace(/[^0-9]/g, '')

  for loc in locs
    input = input.substring(0, loc) + '-' + input.substring(loc, input.length) if input.length >= loc

  textbox.value = input

ssnInput = -> maskInput(this.value, this, [ 3, 6 ], '-')

$ ->
  $("input.ssn").
    on("keydown", filter).
    on("keyup", ssnInput).
    on("blur", ssnInput).
    each(ssnInput)

