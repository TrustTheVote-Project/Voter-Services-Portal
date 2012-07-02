pages  = [ 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]
optionsPageIdx  = pages.indexOf('options')
oathPageIdx     = pages.indexOf('oath')
downloadPageIdx = pages.indexOf('download')

class UpdateRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#registration_residence').val())

    new Popover('#mailing .next.btn', @addressesErrors)
    new Popover('#options .next.btn', @optionsErrors)
    new Popover('#oath .next.btn', @oathErrors)

    # Init absenteeUntil
    rau = $("#registration_absentee_until").val()
    rau = moment().add('days', 45).format("YYYY-MM-DD") if !filled(rau)
    @setAbsenteeUntil(rau)

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


class DownloadRegistration
  constructor: (initPage) ->
    @downloaded = ko.observable(false)
    @downloadSection()
    @sectionComplete = $("#complete.section")
    @currentPageIdx  = ko.observable(initPage)

  markAsDownloaded: =>
    @downloaded(true)
    true

  downloadSection: ->
    @sectionDownload = $("#download.update.section")

    downloadErrors = ko.computed =>
      errors = []
      errors.push("Download your PDF please") unless @downloaded()
      errors

    @downloadInvalid = ko.computed => downloadErrors().length > 0
    new Popover('#download.update .next.btn', downloadErrors)

  gotoComplete: =>
    @sectionDownload.hide()
    @sectionComplete.show()

  gotoDownload: =>
    @sectionComplete.hide()
    @sectionDownload.show()

updateEditLink = ->
  editLink = $("a#edit_registration")
  st = $('input:checked[name="status"]').val()
  path = editLink.attr('href').replace(/edit.*$/, 'edit')
  editLink.attr('href', path + '/' + st)


$ ->
  if $("#update_registration").length > 0
    ko.applyBindings(new UpdateRegistration())

  if $("#download.section").length > 0
    ko.applyBindings(new DownloadRegistration(downloadPageIdx))

  editLink = $("a#edit_registration")
  if editLink.length > 0
    $('input[name="status"]').change(updateEditLink)
    updateEditLink()
