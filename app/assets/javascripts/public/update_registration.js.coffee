class UpdateRegistration
  constructor: ->
    @updateFormSection()
    @oathSection()

  updateFormSection: ->
    @sectionUpdate = $("#update.section")
    @lastName = ko.observable($("#registration_last_name").val())

    updateFormErrors = ko.computed =>
      errors = []
      errors.push('Last name') unless filled(@lastName())
      errors

    @updateFormInvalid = ko.computed => updateFormErrors().length > 0

    new Popover('#update .next.btn', updateFormErrors)

  oathSection: ->
    @sectionOath  = $("#oath.section")
    @infoCorrect  = ko.observable()
    @privacyAgree = ko.observable()

    oathErrors = ko.computed =>
      errors = []
      errors.push("Confirm that information is correct") unless @infoCorrect()
      errors.push("Agree with privacy terms") unless @privacyAgree()
      errors

    @oathInvalid = ko.computed => oathErrors().length > 0
    new Popover('#oath .next.btn', oathErrors)

  gotoOath: =>
    return if @updateFormInvalid()
    @sectionUpdate.hide()
    @sectionOath.show()


  gotoUpdate: =>
    @sectionUpdate.show()
    @sectionOath.hide()

  submit: =>
    $("form.edit_registration")[0].submit()

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

$ ->
  if $("#update.section").length > 0
    ko.applyBindings(new UpdateRegistration())

  if $("#download.update.section").length > 0
    ko.applyBindings(new DownloadRegistration())

