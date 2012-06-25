pages  = [ 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]
oath_page_idx = pages.indexOf('oath')

class UpdateRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#residence').val())

    new Popover('#mailing .next.btn', @addressesErrors)
    new Popover('#options .next.btn', @optionsErrors)
    new Popover('#oath .next.btn', @oathErrors)

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
    if newIdx > oath_page_idx
      @submit()
    else
      location.hash = pages[newIdx]



class DownloadRegistration
  constructor: ->
    @downloaded = ko.observable(false)
    @downloadSection()
    @sectionComplete = $("#complete.section")

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

  editLink = $("a#edit_registration")
  if editLink.length > 0
    $('input[name="status"]').change(updateEditLink)
    updateEditLink()
