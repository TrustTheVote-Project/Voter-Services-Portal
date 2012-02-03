class EligibilitySection extends Forms.Section
  constructor: (navigationListener) ->
    oname           = 'registration_request'
    oid             = "##{oname}"
    @citizenFlag    = $(oid + '_citizen')
    @oldEnoughFlag  = $(oid + '_old_enough')
    @residenceGroup = $("input[name='registration_request[residence]']")
    @votingRightsUnrevoked = $(oid + '_voting_rights_unrevoked')
    @rrReason       = new Forms.RequiredTextField(oid + '_rights_revoke_reason')
    @rrState        = new Forms.RequiredTextField(oid + '_rights_revoked_in_state')
    @rrDate         = new Forms.RequiredDateField(oid + '_rights_restored_on')
    @resideOutside  = $(oid + '_residence_outside')

    @votingRightsGroup = $("input[name='#{oname}[voting_rights]']")
    @outsideTypeGroup  = $("input[name='#{oname}[outside_type]']")

    new Forms.BlockToggleField(oid + '_residence_outside', 'div.outside')
    new Forms.BlockToggleField(oid + '_outside_type_active_duty', 'div.add')
    new Forms.BlockToggleField(oid + '_outside_type_spouse_active_duty', 'div.sadd')
    new Forms.BlockToggleField(oid + '_voting_rights_restored', 'div.restored')

    super '#eligibility', navigationListener

  incompleteItems: ->
    items = []
    items.push('Confirm you are a citizen of U.S.') unless @citizenFlag.is(":checked")
    items.push('Confirm you will be of allowed age') unless @oldEnoughFlag.is(":checked")

    if !@residenceGroup.is(":checked") or (@resideOutside.is(":checked") and !@outsideTypeGroup.is(":checked"))
      items.push('Choose the correct residence status')

    if @votingRightsGroup.is(":checked")
      if !@votingRightsUnrevoked.is(":checked") and (!@rrReason.isValid() or !@rrState.isValid() or !@rrDate.isValid())
        items.push('Provide details of your voting rights restoration')
    else
      items.push('Provide your voting rights status')

    items

  isComplete: =>
    @residenceGroup.is(":checked") and
    @citizenFlag.is(":checked") and
    @oldEnoughFlag.is(":checked") and
    @votingRightsGroup.is(":checked") and
    (@votingRightsUnrevoked.is(":checked") or
      (@rrReason.isValid() and @rrState.isValid() and @rrDate.isValid())) and
    (!@resideOutside.is(":checked") or @outsideTypeGroup.is(":checked"))


class IdentitySection extends Forms.Section
  constructor: (navigationListener) ->
    oid       = '#registration_request'
    @lastName = new Forms.RequiredTextField(oid + '_last_name')
    @dob      = new Forms.RequiredDateField(oid + '_dob')
    @noSSN    = $("#no_ssn")
    @dln      = new Forms.RequiredTextField(oid + '_dln_or_stateid',
                  skip_validation_if: => !@noSSN.is(':checked'))
    @ssn      = new Forms.RequiredTextField(oid + '_ssn', 
                  skip_validation_if: => @noSSN.is(':checked'))

    @noSSN.change(@updateDlnAndSsn)

    new Forms.BlockToggleField('#no_ssn', '.dln')

    super '#identity', navigationListener

  updateDlnAndSsn: =>
    @ssn.onChange()
    @dln.onChange()

  isComplete: =>
    @lastName.isValid() and @dob.isValid() and
    @dln.isValid() and @ssn.isValid()


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


