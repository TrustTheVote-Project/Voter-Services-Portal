class StatusLookup
  constructor: ->
    lookupLink = $("a.new_lookup")
    lookupLink.click ->
      $("#record").fadeOut ->
        $("#search form").fadeIn ->
          lookupLink.hide()

  lookup: =>
    @recordSection.hide()

$ ->
  if $("#status").length > 0
    new StatusLookup()

