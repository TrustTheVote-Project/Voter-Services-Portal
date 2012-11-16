pages           = [ 'eligibility', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]
oathPageIdx     = pages.indexOf('oath')
downloadPageIdx = pages.indexOf('download')
optionsPageIdx  = pages.indexOf('options')


class NewRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#residence').val())

    new Popover('#eligibility .next.btn', @eligibilityErrors)
    new Popover('#identity .next.btn', @identityErrors)
    new Popover('#mailing .next.btn', @addressesErrors)
    new Popover('#options .next.btn', @optionsErrors)
    new Popover('#oath .next.btn', @oathErrors)

    $(".section").show()

    # Navigation
    @currentPageIdx         = ko.observable(initPage)
    @page                   = ko.computed(=> pages[@currentPageIdx()])

    # Reset any hash in the URL
    location.hash = ''

    # Watch for URL changes
    $(window).hashchange =>
      hash = location.hash
      newIdx = $.inArray(hash.replace('#', ''), pages)
      newIdx = 0 if newIdx == -1
      @currentPageIdx(newIdx)

  # --- Navigation
  #
  submit: (f) =>
    $("##{@page()} .next.btn").trigger('click')

  prevPage: => window.history.back()
  nextPage: (_, e) =>
    return if $(e.target).hasClass('disabled')
    newIdx = @currentPageIdx() + 1
    if newIdx > oathPageIdx
      $('form#new_registration')[0].submit()
    else
      location.hash = pages[newIdx]
      @initAbsenteeUntilSlider() if newIdx == optionsPageIdx

$ ->
  if $('form#new_registration').length > 0
    ko.applyBindings(new NewRegistration(0))

  if $("#new_registration_finalization").length > 0
    ko.applyBindings(new Finalization(pages))
