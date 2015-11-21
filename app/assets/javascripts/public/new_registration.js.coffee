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

class NewRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#residence').val())

    new Popover('#eligibility .next.bt', @eligibilityErrors)
    new Popover('#identity .next.bt', @identityErrors)
    new Popover('#mailing .next.bt', @addressesErrors)
    new Popover('#options .next.bt', @optionsErrors)
    new Popover('#oath .next.bt', @oathErrors)

    $(".next.bt").on 'click', (e) ->
      btn = $(this)
      $("input, select", btn.parents(".section")).trigger("validate") if btn.hasClass('disabled')

    # Navigation
    @page = ko.observable('eligibility')
    @step = ko.computed => pageSteps[@page()]

    # Watch for URL changes
    $(window).hashchange =>
      @gotoPage(location.hash.replace('#', ''))

  # --- Navigation
  #
  submit: (f) =>
    $("##{@page()} .next.bt").trigger('click')

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

  submitForm: =>
    $("form#new_registration")[0].submit()


$ ->
  if $('form#new_registration').length > 0
    form = new NewRegistration(0)
    ko.applyBindings(form)
    form.saveOriginalRegAddress()


  if $("#nr_download").length > 0
    ko.applyBindings(new Finalization(pageSteps))
