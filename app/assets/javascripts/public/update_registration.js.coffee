pageSteps = {
  'eligibility':      1,
  'identity':         2,
  'address':          3,
  'options':          4,
  'confirm':          5,
  'oath':             5,
  'submit_online':    5,
  'final':            5,
  'download':         5,
  'congratulations':  5
}

finalizationPageSteps = {
  'view':             1,
  'address':          2,
  'options':          3,
  'final':            4,
  'download':         4,
  'congratulations':  4
}

class UpdateRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#registration_residence').val())

    @augmentEligibilityFields()
    @initConfirmFields()

    # overrides default criteria (see in registration.js)
    @isEligible = ko.computed =>
      @citizen() == '1' and
      @oldEnough() == '1' and
      (!@ssnRequired() or (!@noSSN() and filled(@ssn()))) and
      @hasEligibleRights()

    new Popover('#eligibility .next.bt', @eligibilityErrors)
    new Popover('#identity .next.bt', @identityErrors)
    new Popover('#mailing .next.bt', @addressesErrors)
    if ($("#options .next.bt").length > 0)
      new Popover('#options .next.bt', @optionsErrors)
    new Popover('#oath .next.bt', @oathErrors)
    new Popover('#confirm .next.bt', @confirmErrors)

    # Init absenteeUntil
    rau = $("#registration_absentee_until").val()
    rau = moment().add('days', 45).format("YYYY-MM-DD") if !filled(rau)
    @setAbsenteeUntil(rau)

    # Navigation
    @page = ko.observable('eligibility')
    @step = ko.computed => pageSteps[@page()]

    # Watch for url changes
    $(window).hashchange =>
      @gotoPage(location.hash.replace('#', ''))

    if $("#registration_requesting_absentee:not([disabled])").is(":checked")
      @gotoPage('options')

  validatePersonalData: (errors) ->
    errors.push('Social Security #') if !ssn(@ssn()) and !@noSSN()
    errors.push(gon.i18n_dmvid) if @dmvIdCheckbox and !isDmvId(@dmvId()) and !@noDmvId()

  augmentEligibilityFields: ->
    @dobDay($("input#dob_day").val())
    @dobMonth($("input#dob_month").val())
    @dobYear($("input#dob_year").val())

  initConfirmFields: ->
    @confirmErrors = ko.computed =>
      errors = []
      errors.push("Your surname (last name)") unless filled(@lastName())
      errors
    @confirmInvalid = ko.computed => @confirmErrors().length > 0

  submitForm: ->
    $("form.edit_registration")[0].submit()

  gotoPage: (page, e) =>
    return if e && $(e.target).hasClass('disabled')
    page = 'eligibility' unless filled(page)
    @page(page)
    location.hash = page

  prevPage: => window.history.back()
  eligibilityPage: (_, e) => @gotoPage('eligibility', e)
  nextFromAddress: (_, e) => @gotoPage('options', e)
  nextFromOptions: (_, e) => @gotoPage('confirm', e)
  nextFromConfirm: (_, e) => @gotoPage('oath', e)
  nextFromOath: (_, e) =>
    if $("#oath .next.bt").hasClass('disabled')
      e.preventDefault()
      return

    if @paperlessSubmission()
      @gotoPage('submit_online', e)
    else
      @submitForm()


$ ->
  if $("#update_registration").length > 0
    form = new UpdateRegistration()
    ko.applyBindings(form)
    form.saveOriginalRegAddress()

  if $("#update_finalization").length > 0
    ko.applyBindings(new Finalization(finalizationPageSteps))
