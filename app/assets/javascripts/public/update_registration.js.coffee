pageSteps = {
  'address':          2,
  'options':          3,
  'confirm':          4,
  'oath':             4,
  'final':            4,
  'download':         4,
  'congratulations':  4
}

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
    @paperlessSubmission = ko.observable(false)

    # Navigation
    @page = ko.observable('address')
    @step = ko.computed => pageSteps[@page()]

    # Reset any hash in the URL
    location.hash = ''

    # Watch for url changes
    $(window).hashchange =>
      @gotoPage(location.hash.replace('#', ''))

  initConfirmFields: ->
    @confirmErrors = ko.computed =>
      errors = []
      errors.push("Your last name") unless filled(@lastName())
      errors
    @confirmInvalid = ko.computed => @confirmErrors().length > 0

  submitForm: ->
    $("form.edit_registration")[0].submit()

  gotoPage: (page, e) =>
    return if e && $(e.target).hasClass('disabled')
    @page(page)
    location.hash = page

  prevPage: => window.history.back()
  nextFromAddress: (_, e) => @gotoPage('options', e)
  nextFromOptions: (_, e) => @gotoPage('confirm', e)
  nextFromConfirm: (_, e) => @gotoPage('oath', e)
  nextFromOath: (_, e) =>
    if @paperlessSubmission()
      @gotoPage('submit_online', e)
    else
      @submitForm()

updateEditLink = ->
  editLink = $("a#edit_registration")
  st = $('input:checked[name="status"]').val()
  path = editLink.attr('href').replace(/edit.*$/, 'edit')
  editLink.attr('href', path + '/' + st)


$ ->
  if $("#update_registration").length > 0
    ko.applyBindings(new UpdateRegistration())

  if $("#update_finalization").length > 0
    ko.applyBindings(new Finalization(pageSteps))

  editLink = $("a#edit_registration")
  if editLink.length > 0
    $('input[name="status"]').change(updateEditLink)
    updateEditLink()
