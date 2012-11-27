class StatusLookup
  constructor: ->
    lookupLink = $("a.new_lookup")
    lookupLink.click ->
      lookupLink.fadeOut()
      $("#record").fadeOut ->
        $("#search form").fadeIn()

  lookup: =>
    @recordSection.hide()

$ ->
  if $("#status").length > 0
    new StatusLookup()
