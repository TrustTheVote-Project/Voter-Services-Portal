class EligibilitySection extends Forms.Section
  constructor: (navigationListener) ->
    oid             = '#registration_request'
    @citizenFlag    = $(oid + '_citizen')
    @oldEnoughFlag  = $(oid + '_old_enough')
    @residenceRadio = $("input[name='registration_request[residence]']")
    super 'fieldset#eligibility', navigationListener

  isComplete: =>
    @residenceRadio.is(":checked") and
    @citizenFlag.is(":checked") and
    @oldEnoughFlag.is(":checked")

class IdentitySection extends Forms.Section
  constructor: (navigationListener) ->
    oid       = '#registration_request'
    @lastName = new Forms.RequiredField(oid + '_last_name')
    @gender   = new Forms.RequiredField(oid + '_gender')
    super 'fieldset#identity', navigationListener

  isComplete: =>
    @lastName.isValid() and @gender.isValid()

class Form extends Forms.MultiSectionForm
  constructor: ->
    super [ new EligibilitySection(this), new IdentitySection(this) ], new Forms.StepIndicator(".steps")

$ ->
  return unless $('form#new_registration_request').length > 0

  new Form

  #new Forms.BlockToggleField('input#registration_request_was_convicted', 'div.convicted')
  #new Forms.BlockToggleField('input#registration_request_identify_by_ssn', 'div.ssn')
  #new Forms.BlockToggleField('input#registration_request_identify_by_dln', 'div.dln')
