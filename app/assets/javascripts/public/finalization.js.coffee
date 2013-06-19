class window.Finalization
  constructor: (@pageSteps) ->
    @page = ko.observable("final")
    @step = ko.computed => @pageSteps[@page()]

    if $("#download.section").length > 0
      @downloaded = ko.observable(false)
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
    new Popover('#download.section .done.btn', downloadErrors)

  gotoComplete: =>
    return if @downloadInvalid()
    document.location.href = "/"
