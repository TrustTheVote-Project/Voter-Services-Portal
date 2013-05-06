class window.Finalization
  constructor: (pages) ->
    @pages          = pages
    @currentPageIdx = ko.observable(pages.indexOf("final"))
    @page           = ko.observable("final")
    @downloaded     = ko.observable(false)
    @downloadSection()

  markAsDownloaded: =>
    @downloaded(true)
    true

  downloadSection: ->
    downloadErrors = ko.computed =>
      errors = []
      errors.push("Download your PDF please") unless @downloaded()
      errors

    @downloadInvalid = ko.computed => downloadErrors().length > 0
    new Popover('#download.section .next.btn', downloadErrors)

  gotoComplete: =>
    @page('congratulations')
    @currentPageIdx(@pages.indexOf(@page()))

  gotoDownload: =>
    @page('download')
    @currentPageIdx(@pages.indexOf(@page()))

