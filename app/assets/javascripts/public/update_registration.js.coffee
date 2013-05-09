pages  = [ 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]
optionsPageIdx  = pages.indexOf('options')
oathPageIdx     = pages.indexOf('oath')

class UpdateRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#registration_residence').val())

    @initConfirmFields()

    new Popover('#mailing .next.btn', @addressesErrors)
    new Popover('#options .next.btn', @optionsErrors)
    new Popover('#oath .next.btn', @oathErrors)
    new Popover('#confirm .next.btn', @confirmErrors)

    # Init absenteeUntil
    rau = $("#registration_absentee_until").val()
    rau = moment().add('days', 45).format("YYYY-MM-DD") if !filled(rau)
    @setAbsenteeUntil(rau)

    # There's no DMV matching in update workflow
    @dmvMatch = ko.observable(false)

    # Navigation
    @currentPageIdx         = ko.observable(initPage)
    @page                   = ko.computed(=> pages[@currentPageIdx()])

    # Reset any hash in the URL
    location.hash = ''

    # Watch for url changes
    $(window).hashchange =>
      hash = location.hash
      newIdx = $.inArray(hash.replace('#', ''), pages)
      newIdx = 0 if newIdx == -1
      @currentPageIdx(newIdx)

  initConfirmFields: ->
    @confirmErrors = ko.computed =>
      errors = []
      errors.push("Your last name") unless filled(@lastName())
      errors
    @confirmInvalid = ko.computed => @confirmErrors().length > 0

  submit: ->
    $("form.edit_registration")[0].submit()

  prevPage: -> window.history.back()
  nextPage: (_, e) =>
    return if $(e.target).hasClass('disabled')
    newIdx = @currentPageIdx() + 1
    if newIdx > oathPageIdx
      @submit()
    else
      location.hash = pages[newIdx]
      @initAbsenteeUntilSlider() if newIdx == optionsPageIdx


updateEditLink = ->
  editLink = $("a#edit_registration")
  st = $('input:checked[name="status"]').val()
  path = editLink.attr('href').replace(/edit.*$/, 'edit')
  editLink.attr('href', path + '/' + st)


$ ->
  if $("#update_registration").length > 0
    ko.applyBindings(new UpdateRegistration())

  if $("#update_finalization").length > 0
    ko.applyBindings(new Finalization(pages))

  editLink = $("a#edit_registration")
  if editLink.length > 0
    $('input[name="status"]').change(updateEditLink)
    updateEditLink()
