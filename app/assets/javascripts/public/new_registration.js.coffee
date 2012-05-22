window.stepClass = (current, idx, def) ->
  def = def || 'span2'
  match = if $.isArray(idx) then $.inArray(current, idx) > -1 else idx == current
  max   = if $.isArray(idx) then idx[idx.length - 1] else idx
  (if match then 'current ' else if current > max then 'done ' else '') + def

pages  = [ 'eligibility', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]
oath_page_idx = 5
download_page_idx = 6

filled = (v) -> v && !v.match(/^\s*$/)
join   = (a, sep) -> $.map(a, (i) -> if filled(i) then i else null).join(sep)
zip5   = (v) -> filled(v) && v.match(/^\d{5}$/)
ssn    = (v) -> filled(v) && v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){9}$/)
date   = (y, m, d) -> filled(y) && filled(m) && filled(d) && moment([y, m, d]).diff(new Date()) < 0
phone  = (v) -> v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){10}$/)
email  = (v) -> v.match(/^\S+@\S+\.\S+$/)

ko.bindingHandlers.vis = {
  update: (element, valueAccessor) ->
    value = ko.utils.unwrapObservable(valueAccessor())
    isCurrentlyVisible = !(element.style.display == "none")
    if value && !isCurrentlyVisible
      element.style.display = "block"
    else if !value && isCurrentlyVisible
      element.style.display = "none"
}

class Popover
  constructor: (id, errors) ->
    @errors = errors
    @el = $(id).popover(content: @popoverContent, title: 'Please review', html: 'html')
    @po = @el.data().popover

    errors.subscribe @update
    @update()

  update: =>
    @po.enabled = @errors().length > 0

  popoverContent: =>
    items = @errors()
    if items.length > 0
      "<ul>#{('<li>' + i + '</li>' for i in items).join('')}</ul>"
    else
      null

class NewRegistration
  constructor: (initPage = 0) ->
    self      = this
    @oname    = 'registration_request'
    oid       = "##{@oname}"

    overseas  = $('input#overseas').val() == '1'

    @eligibilitySection(overseas)
    @identitySection(overseas)
    @addressSection(overseas)
    @optionsSection(overseas)
    @oathSection()
    @summarySection()

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

  # --- Sections

  eligibilitySection: (overseas) =>
    @isCitizen              = ko.observable()
    @isOldEnough            = ko.observable()
    @residence              = ko.observable(if overseas then 'outside' else 'in')
    @overseas               = ko.computed => @residence() == 'outside'
    @domestic               = ko.computed => !@overseas()
    @rightsWereRevoked      = ko.observable()
    @rightsRevokationReason = ko.observable()
    @rightsWereRestored     = ko.observable()
    @rightsRestoredOnMonth  = ko.observable()
    @rightsRestoredOnYear   = ko.observable()
    @rightsRestoredOnDay    = ko.observable()

    @eligibilityErrors = ko.computed =>
      errors = []
      errors.push("Citizenship criteria") unless @isCitizen()
      errors.push("Age criteria") unless @isOldEnough()
      errors.push("Voting rights criteria") unless (@rightsWereRevoked() == 'no' or (@rightsRevokationReason() and @rightsWereRestored() == 'yes' and date(@rightsRestoredOnYear(), @rightsRestoredOnMonth(), @rightsRestoredOnDay())))
      errors

    @eligibilityInvalid = ko.computed => @eligibilityErrors().length > 0
    new Popover('#eligibility .next.btn', @eligibilityErrors)

  identitySection: (overseas) =>
    @firstName              = ko.observable()
    @middleName             = ko.observable()
    @lastName               = ko.observable()
    @suffix                 = ko.observable()
    @dobYear                = ko.observable()
    @dobMonth               = ko.observable()
    @dobDay                 = ko.observable()
    @gender                 = ko.observable()
    @ssn                    = ko.observable()
    @noSSN                  = ko.observable()
    @phone                  = ko.observable()
    @email                  = ko.observable()

    @identityErrors = ko.computed =>
      errors = []
      errors.push('Last name') unless filled(@lastName())
      errors.push('Date of birth') unless filled(@dobYear()) and filled(@dobMonth()) and filled(@dobDay())
      errors.push('Gender') unless filled(@gender())
      errors.push('Social Security #') unless ssn(@ssn()) and !@noSSN()
      errors.push('Phone number') unless !filled(@phone()) or phone(@phone())
      errors.push('Email address') unless !filled(@email()) or email(@email())
      errors

    @identityInvalid = ko.computed => @identityErrors().length > 0
    new Popover('#identity .next.btn', @identityErrors)

  addressSection: (overseas) =>
    @vvrIsRural             = ko.observable(false)
    @vvrRural               = ko.observable()
    @maIsSame               = ko.observable('yes')
    @hasExistingReg         = ko.observable('no')
    @erIsRural              = ko.observable(false)
    @vvrStreetNumber        = ko.observable()
    @vvrStreetName          = ko.observable()
    @vvrStreetType          = ko.observable()
    @vvrApt                 = ko.observable()
    @vvrTown                = ko.observable()
    @vvrState               = ko.observable('VA')
    @vvrZip5                = ko.observable()
    @vvrZip4                = ko.observable()
    @vvrCountyOrCity        = ko.observable()
    @vvrCountySelected      = ko.computed => String(@vvrCountyOrCity()).match(/\s+county/i)
    @vvrOverseasRA          = ko.observable()
    @maAddress1             = ko.observable()
    @maAddress2             = ko.observable()
    @maCity                 = ko.observable()
    @maState                = ko.observable()
    @maZip5                 = ko.observable()
    @maZip4                 = ko.observable()
    @mauType                = ko.observable()
    @mauAPOAddress1         = ko.observable()
    @mauAPOAddress2         = ko.observable()
    @mauAPO1                = ko.observable()
    @mauAPO2                = ko.observable()
    @mauAPOZip5             = ko.observable()
    @mauAddress             = ko.observable()
    @mauAddress2            = ko.observable()
    @mauCity                = ko.observable()
    @mauState               = ko.observable()
    @mauPostalCode          = ko.observable()
    @mauCountry             = ko.observable()
    @erStreetNumber         = ko.observable()
    @erStreetName           = ko.observable()
    @erStreetType           = ko.observable()
    @erCity                 = ko.observable()
    @erState                = ko.observable()
    @erZip5                 = ko.observable()
    @erIsRural              = ko.observable()
    @erRural                = ko.observable()
    @erCancel               = ko.observable()

    @domesticMAFilled = ko.computed =>
      @maIsSame() == 'yes' or
      filled(@maAddress1()) and
      filled(@maCity()) and
      filled(@maState()) and
      zip5(@maZip5())

    @nonUSMAFilled = ko.computed =>
      filled(@mauAddress()) and
      filled(@mauCity()) and
      filled(@mauState()) and
      filled(@mauPostalCode()) and
      filled(@mauCountry())

    @overseasMAFilled = ko.computed =>
      if   @mauType() == 'apo'
      then filled(@mauAPO1()) and filled(@mauAPO2()) and zip5(@mauAPOZip5())
      else @nonUSMAFilled()

    @addressesErrors = ko.computed =>
      errors = []

      residental =
        if   @vvrIsRural()
        then filled(@vvrRural())
        else filled(@vvrStreetNumber()) and
             filled(@vvrStreetName()) and
             filled(@vvrTown()) and
             filled(@vvrState()) and
             zip5(@vvrZip5()) and
             filled(@vvrCountyOrCity())

      if @overseas()
        residental = residental and filled(@vvrOverseasRA())
        mailing = @overseasMAFilled()
      else
        mailing = @domesticMAFilled()

      existing =
        @hasExistingReg() == 'no' or
        @erCancel() and
        if   @erIsRural()
        then filled(@erRural())
        else filled(@erStreetNumber()) and
             filled(@erStreetName()) and
             filled(@erCity()) and
             filled(@erState()) and
             zip5(@erZip5())

      errors.push("Registration address") unless residental
      errors.push("Mailing address") unless mailing
      errors.push("Existing registration") unless existing
      errors

    @addressesInvalid = ko.computed => @addressesErrors().length > 0
    new Popover('#mailing .next.btn', @addressesErrors)

  optionsSection: (overseas) =>
    @isConfidentialAddress  = ko.observable(false)
    @caType                 = ko.observable()
    @requestingAbsentee     = ko.observable(overseas)
    @rabElection            = ko.observable()
    @rabElectionName        = ko.observable()
    @rabElectionDate        = ko.observable()
    @abSendTo               = ko.observable()
    @outsideType            = ko.observable()
    @needsServiceDetails    = ko.computed => @outsideType() && @outsideType().match(/duty/)
    @serviceId              = ko.observable()
    @rank                   = ko.observable()

    @abSchoolName           = ko.observable()
    @abStreetNumber         = ko.observable()
    @abStreetName           = ko.observable()
    @abStreetType           = ko.observable()
    @abCity                 = ko.observable()
    @abState                = ko.observable()
    @abZip5                 = ko.observable()
    @abCountry              = ko.observable()

    @abSTAddress            = ko.observable()
    @abSTCity               = ko.observable()
    @abSTState              = ko.observable()
    @abSTZip5               = ko.observable()
    @abSTCountry            = ko.observable()

    @optionsErrors = ko.computed =>
      errors = []
      if @requestingAbsentee()
        if @overseas()
          errors.push("Absense type") unless filled(@outsideType())
          errors.push("Service details") if @needsServiceDetails() and (!filled(@serviceId()) || !filled(@rank()))
        else
          if !filled(@rabElection()) or (@rabElection() == 'other' and (!filled(@rabElectionName()) or !filled(@rabElectionDate())))
            errors.push("Election details")

          if !filled(@abSchoolName()) or
            !filled(@abStreetNumber()) or
            !filled(@abSchoolName()) or
            !filled(@abCity()) or
            !filled(@abState()) or
            !zip5(@abZip5()) or
            !filled(@abCountry())
              errors.push("School details")

        if !filled(@abSendTo()) or
          (@abSendTo() == 'other' and
          ( !filled(@abSTAddress()) or
            !filled(@abSTCity()) or
            !filled(@abSTState()) or
            !zip5(@abSTZip5()) or
            !filled(@abSTCountry()) ) )
              errors.push("Absentee ballot destination")

      errors

    @optionsInvalid = ko.computed => @optionsErrors().length > 0
    new Popover('#options .next.btn', @optionsErrors)

  oathSection: =>
    @infoCorrect  = ko.observable()
    @privacyAgree = ko.observable()

    @oathErrors = ko.computed =>
      errors = []
      errors.push("Confirm that information is correct") unless @infoCorrect()
      errors.push("Agree with privacy terms") unless @privacyAgree()
      errors

    @oathInvalid = ko.computed => @oathErrors().length > 0
    new Popover('#oath .next.btn', @oathErrors)


  summarySection: =>
    @summaryFullName = ko.computed =>
      join([ @firstName(), @middleName(), @lastName(), @suffix() ], ' ')

    @summaryDOB = ko.computed =>
      if filled(@dobMonth()) && filled(@dobDay()) && filled(@dobYear())
        moment([ @dobYear(), parseInt(@dobMonth()) - 1, @dobDay() ]).format("MMMM D, YYYY")

    @summaryRegistrationAddress = ko.computed =>
      if @vvrIsRural()
        @vvrRural()
      else
        join([ join([ @vvrStreetNumber(), @vvrApt() ], '/'), @vvrStreetName(), @vvrStreetType() ], ' ') + "<br/>" +
        join([ @vvrTown(), join([ @vvrState(), join([ @vvrZip5(), @vvrZip4() ], '-') ], ' ') ], ', ')

    @summaryOverseasMailingAddress = ko.computed =>
      if @mauType() == 'apo'
        join([
          @mauAPOAddress1(),
          @mauAPOAddress2(),
          join([ @mauAPO1(), @mauAPO2(), @mauAPOZip5() ], ', ')
        ], "<br/>")
      else
        join([
          @mauAddress(),
          @mauAddress2(),
          join([ @mauCity(), join([ @mauState(), @mauPostalCode()], ' '), @mauCountry()], ', ')
        ], "<br/>")


    @summaryDomesticMailingAddress = ko.computed =>
      join([
        @maAddress1(),
        @maAddress2(),
        join([ @maCity(), join([ @maState(), join([ @maZip5(), @maZip4()], '-')], ' ')], ', ')
      ], "<br/>")

    @summaryMailingAddress = ko.computed =>
      if @overseas()
        @summaryOverseasMailingAddress()
      else
        if @maIsSame() == 'yes'
          @summaryRegistrationAddress()
        else
          @summaryDomesticMailingAddress()

    @summaryStatus = ko.computed => if @requestingAbsentee() then 'Absentee' else 'In person'


  # --- Navigation
  submit: (f) =>
    $("##{@page()} .next.btn").trigger('click')

  prevPage: => window.history.back()
  nextPage: (_, e) =>
    return if $(e.target).hasClass('disabled')
    newIdx = @currentPageIdx() + 1
    if newIdx > oath_page_idx
      $('form#new_registration_request')[0].submit()
    else
      location.hash = pages[newIdx]

class DownloadRegistration
  constructor: ->
    $(".section").show()

    # Navigation
    @currentPageIdx         = ko.observable(download_page_idx)
    @page                   = ko.computed(=> pages[@currentPageIdx()])

    $(window).hashchange =>
      hash = location.hash
      newIdx = $.inArray(hash.replace('#', ''), pages)
      newIdx = download_page_idx if newIdx == -1
      @currentPageIdx(newIdx)

  # --- Navigation

  prevPage: => window.history.back()
  nextPage: (_, a) =>
    return if $(a.target).hasClass('disabled')
    newIdx = @currentPageIdx() + 1
    location.hash = pages[newIdx]

$ ->
  if $('form#new_registration_request').length > 0
    ko.applyBindings(new NewRegistration(0))

  if $('#registration #download').length > 0
    ko.applyBindings(new DownloadRegistration())

