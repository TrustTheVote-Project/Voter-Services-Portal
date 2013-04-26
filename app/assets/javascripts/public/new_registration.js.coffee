pages                 = [ 'eligibility', 'lookup_record', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations', 'registered_info' ]
eligibilityPageIdx    = pages.indexOf('eligibility')
lookupRecordPageIdx   = pages.indexOf('lookup_record')
identityPageIdx       = pages.indexOf('identity')
oathPageIdx           = pages.indexOf('oath')
downloadPageIdx       = pages.indexOf('download')
optionsPageIdx        = pages.indexOf('options')
registeredInfoPageIdx = pages.indexOf('registered_info')


class NewRegistration extends Registration
  constructor: (initPage = 0) ->
    super($('input#residence').val())

    @dmvMatch = ko.observable()

    new Popover('#eligibility .next.btn', @eligibilityErrors)
    new Popover('#identity .next.btn', @identityErrors)
    new Popover('#mailing .next.btn', @addressesErrors)
    new Popover('#options .next.btn', @optionsErrors)
    new Popover('#oath .next.btn', @oathErrors)

    $(".section").show()

    # Navigation
    @currentPageIdx         = ko.observable(initPage)
    @page                   = ko.computed(=> pages[@currentPageIdx()])

    # Reset any hash in the URL
    location.hash = ''

    # Watch for URL changes
    $(window).hashchange =>
      hash = location.hash
      newIdx = $.inArray(hash.replace('#', ''), pages)
      newIdx = 0 if newIdx == -1
      @currentPageIdx(newIdx)

  # --- Navigation
  #
  submit: (f) =>
    $("##{@page()} .next.btn").trigger('click')

  eligibilityPage: =>
    @currentPageIdx(eligibilityPageIdx)

  lookupRecord: =>
    @currentPageIdx(lookupRecordPageIdx)

    revoked = @rightsWereRevoked() && !@rightsWereRestored()
    reason  = @rightsRevokationReason()
    rfelony = revoked && reason == 'felony'
    rmental = revoked && reason == 'mental'

    $.getJSON '/lookup/registration', { record: {
        eligible_citizen:             if @isCitizen() then '1' else '0',
        eligible_18_next_election:    if @isOldEnough() then '1' else '0',
        eligible_revoked_felony:      if rfelony then '1' else '0',
        eligible_revoked_competence:  if rmental then '1' else '0',
        dob:                          "#{@dobMonth()}/#{@dobDay()}/#{@dobYear()}",
        ssn:                          @ssn(),
        dmv_id:                       if @noDmvId() then '' else @dmvId()
      }}, (data) =>
        if data.registered
          @currentPageIdx(registeredInfoPageIdx)
        else
          @dmvMatch(data.dmv_match)
          @currentPageIdx(identityPageIdx)

  prevPage: => window.history.back()
  nextPage: (_, e) =>
    return if $(e.target).hasClass('disabled')
    newIdx = @currentPageIdx() + 1
    if newIdx > oathPageIdx
      $('form#new_registration')[0].submit()
    else
      location.hash = pages[newIdx]
      @initAbsenteeUntilSlider() if newIdx == optionsPageIdx

$ ->
  if $('form#new_registration').length > 0
    ko.applyBindings(new NewRegistration(0))

  if $("#new_registration_finalization").length > 0
    ko.applyBindings(new Finalization(pages))
