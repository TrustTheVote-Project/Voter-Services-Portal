# Eligibility section
class EligibilitySection extends Forms.Section
  constructor: (navigationListener) ->
    @oname  = 'registration_request'
    oid     = "##{@oname}"
    section = $('#eligibility')

    # Fields
    @citizen            = $("#{oid}_citizen")
    @age                = $("#{oid}_old_enough")
    @residence          = $("input[name='#{@oname}[residence]']")
    @residenceInside    = $("#{oid}_residence_in")
    @livingOutside      = $("input[name='#{@oname}[outside_type]']")
    @oaServiceId        = $("#{oid}_outside_active_service_id")
    @oaRank             = $("#{oid}_outside_active_rank")
    @osServiceId        = $("#{oid}_outside_spouse_service_id")
    @osRank             = $("#{oid}_outside_spouse_rank")
    @convicted          = $("input[name='#{@oname}[convicted]']")
    @convictedRestored  = $("#{oid}_convicted_restored")
    @convictedFalse     = $("#{oid}_convicted_false")
    @mental             = $("input[name='#{@oname}[mental]']")
    @mentalRestored     = $("#{oid}_mental_restored")
    @mentalFalse        = $("#{oid}_mental_false")

    # Configure feedback popover on Next button
    btnNext = $('button.next', section)
    popover = new Feedback.Popover(btnNext)
    popover.addItem(new Feedback.Checked(@citizen, 'Citizenship criteria'))
    popover.addItem(new Feedback.Checked(@age, 'Age criteria'))
    popover.addItem(new Feedback.Checked(@residence, 'Residence selection'))
    popover.addItem(new Feedback.Checked(@livingOutside, 'Reason for living outside', skipIf: => !@residenceOutside()))
    popover.addItem(new Feedback.Filled(@oaServiceId, 'Your service ID', skipIf: => !@outsideActive()))
    popover.addItem(new Feedback.Filled(@oaRank, 'Your rank / grade / rate', skipIf: => !@outsideActive()))
    popover.addItem(new Feedback.Filled(@osServiceId, 'Your spouse\'s service ID', skipIf: => !@outsideSpouse()))
    popover.addItem(new Feedback.Filled(@osRank, 'Your spouse\'s rank / grade / rate', skipIf: => !@outsideSpouse()))
    popover.addItem(new Feedback.Checked(@convicted, 'Convictions status'))
    popover.addItem(new Feedback.Checked(@mental, 'Mental status'))
    unrestoredRights = "You can't vote until your rights are restored"
    popover.addItem(new Feedback.Checked(@convictedRestored, unrestoredRights, skipIf: => @convictedFalse.is(":checked") or !@convicted.is(":checked") ))
    popover.addItem(new Feedback.Checked(@mentalRestored, unrestoredRights, skipIf: => @mentalFalse.is(":checked") or !@mental.is(":checked") ))

    new Forms.BlockToggleField(oid + '_residence_outside', 'div.outside')
    new Forms.BlockToggleField(oid + '_outside_type_active_duty', 'div.add')
    new Forms.BlockToggleField(oid + '_outside_type_spouse_active_duty', 'div.sadd')
    new Forms.BlockToggleField(oid + '_convicted_true', '.convicted-details')
    new Forms.BlockToggleField(oid + '_convicted_restored', '.convicted-details .restored')
    new Forms.BlockToggleField(oid + '_mental_true', '.mental-details')
    new Forms.BlockToggleField(oid + '_mental_restored', '.mental-details .restored')

    super '#eligibility', navigationListener

  residenceType: -> $("input:checked[name='#{@oname}[residence]']").val()
  residenceOutside: -> @residenceType() == 'outside'
  outsideType: -> $("input:checked[name='#{@oname}[outside_type]']").val()
  outsideActive: -> @residenceOutside() and @outsideType() == 'active_duty'
  outsideSpouse: -> @residenceOutside() and @outsideType() == 'spouse_active_duty'

  isComplete: =>
    @checked(@citizen) and @checked(@age) and
      (@checked(@residenceInside) or
        (@outsideType() == 'active_duty' and @filled(@oaServiceId) and @filled(@oaRank)) or
        (@outsideType() == 'spouse_active_duty' and @filled(@osServiceId) and @filled(@osRank)) or
        (@outsideType() or '').match(/temporarily/)) and
      (@checked(@convictedFalse) or @checked(@convictedRestored)) and
      (@checked(@mentalFalse) or @checked(@mentalRestored))



# Identify Yourself section
class IdentitySection extends Forms.Section
  constructor: (navigationListener) ->
    oname   = 'registration_request'
    oid     = "##{oname}"
    section = $('#identity')

    # Fields
    @lastName = $("#{oid}_last_name")
    @gender   = $("#{oid}_gender")
    @gender   = false if @gender.length == 0
    @ssn      = $("#{oid}_ssn")
    @dln      = $("#{oid}_dln")
    @noSsn    = $("#{oid}_no_ssn")

    # Configure feedback popover on Next button
    popover = new Feedback.Popover($('button.next', section))
    popover.addItem(new Feedback.Filled(@lastName, 'Last name'))
    popover.addItem(new Feedback.Filled(@gender, 'Gender')) if @gender
    popover.addItem(new Feedback.Filled(@ssn, 'Social Security #', skipIf: => @noSsn.is(":checked")))
    popover.addItem(new Feedback.Filled(@dln, 'Drivers license or State ID', skipIf: => !@noSsn.is(":checked")))

    new Forms.BlockToggleField("#{oid}_no_ssn", '.dln')

    super '#identity', navigationListener

  validSsn: ->
    @ssn.val().match(new RegExp(@ssn.attr('data-format'), 'gi'))

  validDln: ->
    @dln.val().match(new RegExp(@dln.attr('data-format'), 'gi'))

  isComplete: =>
    return @filled(@lastName) and
      (!@gender or @filled(@gender)) and
      (if @checked(@noSsn) then @validDln() else @validSsn())



class ContactInfoSection extends Forms.Section
  constructor: (navigationListener) ->
    oname    = 'registration_request'
    oid      = "##{oname}"
    @section = $('#contact_info')

    @residenceOutside = $("#{oid}_residence_outside").change(@onResidenceChange)

    @vvrCityOrCounty = $("#{oid}_vvr_county_or_city")
    @vvrStreetNumber = $("#{oid}_vvr_street_number")
    @vvrStreetName   = $("#{oid}_vvr_street_name")
    @vvrTown         = $("#{oid}_vvr_town_or_city")
    @vvrZip5         = $("#{oid}_vvr_zip5")
    @vvrIsRural      = $("#{oid}_vvr_is_rural")
    @vvrRural        = $("#{oid}_vvr_rural")
    @vvrUocavaResidenceAvailable = $("input[name='#{oname}[vvr_uocava_residence_available]']")

    @raaAddress      = $("#{oid}_raa_address")
    @raaPostalCode   = $("#{oid}_raa_postal_code")
    @raaCountry      = $("#{oid}_raa_country")

    @maOther         = $("#{oid}_ma_other")
    @maAddress       = $("#{oid}_ma_address")
    @maCity          = $("#{oid}_ma_city")
    @maZip5          = $("#{oid}_ma_zip5")
    @maIsRural       = $("#{oid}_ma_is_rural")
    @maRural         = $("#{oid}_ma_rural")

    @mauTypeOptions  = $("input[name='#{oname}[mau_type]']")
    @mauTypeNonUs    = $("#{oid}_mau_type_non-us")
    @mauAddress      = $("#{oid}_mau_address")
    @mauPostalCode   = $("#{oid}_mau_postal_code")
    @mauCountry      = $("#{oid}_mau_country")

    @apoAddress      = $("#{oid}_apo_address")
    @apoZip5         = $("#{oid}_apo_zip5")

    @confidentiality = $("#{oid}_is_confidential_address")
    @confidentialityOptions = $("input[name='#{oname}[ca_type]']")

    @existinRegOptions = $("input[name='#{oname}[has_existing_reg]']")
    @hasExistinReg   = $("#{oid}_has_existing_reg_true")
    @erAddress       = $("#{oid}_er_address")
    @erCity          = $("#{oid}_er_city")
    @erZip5          = $("#{oid}_er_zip5")
    @erIsRural       = $("#{oid}_er_is_rural")
    @erRural         = $("#{oid}_er_rural")

    new Forms.BlockToggleField("#{oid}_vvr_uocava_residence_available_false", '.residence_unavailable')
    new Forms.BlockToggleField("#{oid}_mau_type_non-us", '.maut-non-us')
    new Forms.BlockToggleField("#{oid}_mau_type_apo", '.maut-apo')
    new Forms.BlockToggleField("#{oid}_is_confidential_address", '.confidental_address')
    new Forms.BlockToggleField("#{oid}_has_existing_reg_true", '.existing_reg')
    new Forms.BlockToggleField("#{oid}_ma_other", '.ma_other')
    new Forms.BlockToggleField("#{oid}_vvr_is_rural", '.vvr_rural', '.vvr_common')
    new Forms.BlockToggleField("#{oid}_ma_is_rural", '.ma_rural', '.ma_common')
    new Forms.BlockToggleField("#{oid}_er_is_rural", '.er_rural', '.er_common')

    # DEBUG
    # @residenceOutside.attr('checked', 'checked')

    votingResidenceSection = new Feedback.CustomItem('Voting residence',
      isComplete: @isVotingResidenceComplete,
      watch: [ @vvrCityOrCounty, @vvrStreetNumber, @vvrStreetName, @vvrTown, @vvrZip5, @vvrIsRural, @vvrRural, @vvrUocavaResidenceAvailable ])

    residentalAddressAbroadSection = new Feedback.CustomItem('Residental address abroad',
      isComplete: @isResidentalAddressAbroadComplete,
      watch: [ @raaAddress, @raaPostalCode, @raaCountry ])

    mailingAddressSection = new Feedback.CustomItem('Mailing address',
      isComplete: @isMailingAddressComplete,
      watch: [ @maOther, @maAddress, @maCity, @maZip5, @maIsRural, @maRural, @mauTypeOptions, @mauAddress, @mauPostalCode, @mauCountry, @apoAddress, @apoZip5 ])

    confidentialitySection = new Feedback.CustomItem('Confidentiality reasons',
      isComplete: @isConfidentialityComplete,
      watch: [ @confidentiality, @confidentialityOptions ])

    existingRegistrationSection = new Feedback.CustomItem('Existing registration address',
      isComplete: @isExistinRegistrationComplete,
      watch: [ @existinRegOptions, @erAddress, @erCity, @erZip5, @erIsRural, @erRural ])

    # Configure feedback popover on Next button
    popover = new Feedback.Popover($('button.next', @section))
    popover.addItem(votingResidenceSection)
    popover.addItem(residentalAddressAbroadSection)
    popover.addItem(mailingAddressSection)
    popover.addItem(confidentialitySection)
    popover.addItem(existingRegistrationSection)

    @vvrCityOrCounty.change(@onCityCountyChange)
    @onCityCountyChange()

    @onResidenceChange()
    super '#contact_info', navigationListener

  onCityCountyChange: =>
    cc = @vvrCityOrCounty.val()
    if cc.match('CITY')
      @vvrTown.val(cc).attr('readonly', 'readonly')
    else
      @vvrTown.val('').removeAttr('readonly')

  isUocava: -> @residenceOutside.is(':checked')

  isVotingResidenceComplete: =>
    rural = @checked(@vvrIsRural)
    @filled(@vvrCityOrCounty) and
      ((rural  and @filled(@vvrRural)) or
       (!rural and @filled(@vvrStreetNumber) and @filled(@vvrStreetName) and @filled(@vvrTown) and @filled(@vvrZip5))) and
    (!@isUocava() or @checked(@vvrUocavaResidenceAvailable))

  isResidentalAddressAbroadComplete: =>
    !@isUocava() or
      (@filled(@raaAddress) and @filled(@raaPostalCode) and @filled(@raaCountry))

  isMailingAddressComplete: =>
    if @isUocava()
      @checked(@mauTypeOptions) and
      (if @checked(@mauTypeNonUs) then (@filled(@mauAddress) and @filled(@mauPostalCode) and @filled(@mauCountry)) else (@filled(@apoAddress) and @filled(@apoZip5)))
    else
      !@checked(@maOther) or
      (if @checked(@maIsRural) then @filled(@maRural) else (@filled(@maAddress) and @filled(@maCity) and @filled(@maZip5)))

  isConfidentialityComplete: =>
    !@checked(@confidentiality) or @checked(@confidentialityOptions)

  isExistinRegistrationComplete: =>
    @checked(@existinRegOptions) and
      (!@checked(@hasExistinReg) or
       (if @checked(@erIsRural) then @filled(@erRural) else (@filled(@erAddress) and @filled(@erCity) and @filled(@erZip5))))

  onResidenceChange: =>
    uocava   = $(".uocava", @section)
    domestic = $(".domestic", @section)
    if @isUocava()
      uocava.show()
      domestic.hide()
    else
      uocava.hide()
      domestic.show()

  isComplete: =>
    @isVotingResidenceComplete() and
    @isResidentalAddressAbroadComplete() and
    @isMailingAddressComplete() and
    @isConfidentialityComplete() and
    @isExistinRegistrationComplete()



class CompleteRegistrationSection extends Forms.Section
  constructor: (navigationListener) ->
    @oname  = 'registration_request'
    oid     = "##{@oname}"
    section = $('#complete_registration')

    @infoCorrect  = $("#{oid}_information_correct")
    @privacyAgree = $("#{oid}_privacy_agree")

    # Configure feedback popover on Next button
    popover = new Feedback.Popover($('button.next', section))
    popover.addItem(new Feedback.Checked(@infoCorrect, 'Confirm the information is correct'))
    popover.addItem(new Feedback.Checked(@privacyAgree, 'Agree with privacy terms'))

    super '#complete_registration', navigationListener

  isComplete: =>
    @checked(@infoCorrect) and @checked(@privacyAgree)



class Form extends Forms.MultiSectionForm
  constructor: ->
    super [
      new EligibilitySection(this),
      new IdentitySection(this),
      new ContactInfoSection(this),
      new CompleteRegistrationSection(this)
    ], new Forms.StepIndicator(".steps")

  onSubmit: ->
    $('form#new_registration_request').submit()


$ ->
  return unless $('form#new_registration_request').length > 0
  new Form


