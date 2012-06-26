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


class DownloadRegistration
  constructor: ->
    $(".section").show()

    @downloaded = ko.observable(false)
    @downloadSection()

    # Navigation
    @currentPageIdx         = ko.observable(downloadPageIdx)
    @page                   = ko.computed(=> pages[@currentPageIdx()])

    $(window).hashchange =>
      hash = location.hash
      newIdx = $.inArray(hash.replace('#', ''), pages)
      newIdx = downloadPageIdx if newIdx == -1
      @currentPageIdx(newIdx)

  markAsDownloaded: =>
    @downloaded(true)
    true

  downloadSection: ->
    downloadErrors = ko.computed =>
      errors = []
      errors.push("Download your PDF please") unless @downloaded()
      errors

    @downloadInvalid = ko.computed => downloadErrors().length > 0
    new Popover('#download .next.btn', downloadErrors)

  # --- Navigation

  prevPage: => window.history.back()
  nextPage: (_, a) =>
    return if $(a.target).hasClass('disabled')
    newIdx = @currentPageIdx() + 1
    location.hash = pages[newIdx]

$ ->
  if $('form#new_registration').length > 0
    ko.applyBindings(new NewRegistration(0))

  if $('#registration #download').length > 0
    ko.applyBindings(new DownloadRegistration())

