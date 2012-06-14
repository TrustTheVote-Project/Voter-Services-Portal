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
    alert('submit')

$ ->
  return if $("#update.section").length == 0

  ko.applyBindings(new UpdateRegistration())
