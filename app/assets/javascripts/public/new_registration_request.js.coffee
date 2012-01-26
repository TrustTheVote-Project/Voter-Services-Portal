class EligibilitySection extends Forms.Section
  constructor: (navigationListener) ->
    oid             = '#registration_request'
    @citizenFlag    = $(oid + '_citizen')
    @oldEnoughFlag  = $(oid + '_old_enough')
    @residenceRadio = $("input[name='registration_request[residence]']")
    super '#eligibility', navigationListener

  isComplete: =>
    @residenceRadio.is(":checked") and
    @citizenFlag.is(":checked") and
    @oldEnoughFlag.is(":checked")

class IdentitySection extends Forms.Section
  constructor: (navigationListener) ->
    oid       = '#registration_request'
    @lastName = new Forms.RequiredField(oid + '_last_name')
    @gender   = new Forms.RequiredField(oid + '_gender')
    @dlnOrSsn = new Forms.RequiredField(oid + '_dln_or_ssn')

    new Forms.BlockToggleField(oid + '_was_convicted', 'div.convicted')

    super '#identity', navigationListener

  isComplete: =>
    @lastName.isValid() and @gender.isValid() and @dlnOrSsn.isValid()

class ContactInfoSection extends Forms.Section
  constructor: (navigationListener) ->
    new Forms.BlockToggleField('#registered_in_another_state', '#another_state')
    super '#contact_info', navigationListener

class Form extends Forms.MultiSectionForm
  constructor: ->
    super [
      new EligibilitySection(this),
      new IdentitySection(this),
      new ContactInfoSection(this),
    ], new Forms.StepIndicator(".steps")

$ ->
  return unless $('form#new_registration_request').length > 0
  new Form


