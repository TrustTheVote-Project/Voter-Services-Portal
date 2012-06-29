class window.Registration
  constructor: (residence) ->
    @residence  = ko.observable(residence)
    @overseas   = ko.computed => @residence() == 'outside'
    @domestic   = ko.computed => !@overseas()

    @initEligibilityFields()
    @initIdentityFields()
    @initAddressFields()
    @initOptionsFields()
    @initSummaryFields()
    @initOathFields()

  initEligibilityFields: ->
    @isCitizen              = ko.observable()
    @isOldEnough            = ko.observable()
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

  initIdentityFields: ->
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

  initAddressFields: ->
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
    @vvrUocavaResidenceUnavailableSinceDay = ko.observable()
    @vvrUocavaResidenceUnavailableSinceMonth = ko.observable()
    @vvrUocavaResidenceUnavailableSinceYear = ko.observable()
    @maAddress1             = ko.observable()
    @maAddress2             = ko.observable()
    @maCity                 = ko.observable()
    @maState                = ko.observable()
    @maZip5                 = ko.observable()
    @maZip4                 = ko.observable()
    @mauType                = ko.observable('non-us')
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
      then filled(@mauAPO1()) and zip5(@mauAPOZip5())
      else @nonUSMAFilled()

    @addressesErrors = ko.computed =>
      errors = []

      residental =
        if   @vvrIsRural()
        then filled(@vvrRural())
        else filled(@vvrStreetNumber()) and
             filled(@vvrStreetName()) and
             filled(@vvrStreetType()) and
             (!@vvrCountySelected() or filled(@vvrTown())) and
             filled(@vvrState()) and
             zip5(@vvrZip5()) and
             filled(@vvrCountyOrCity())

      if @overseas()
        residental = residental and
          filled(@vvrOverseasRA()) and
          (@vvrOverseasRA() == 'yes' or (
            filled(@vvrUocavaResidenceUnavailableSinceDay()) and
            filled(@vvrUocavaResidenceUnavailableSinceMonth()) and
            filled(@vvrUocavaResidenceUnavailableSinceYear())))
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

  initOptionsFields: ->
    @party                  = ko.observable()
    @chooseParty            = ko.observable()
    @otherParty             = ko.observable()

    @caType                 = ko.observable()
    @isConfidentialAddress  = ko.observable()
    @requestingAbsentee     = ko.observable()
    @absenteeUntil          = ko.observable()
    @rabElection            = ko.observable()
    @rabElectionName        = ko.observable()
    @rabElectionDate        = ko.observable()
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

    @absenteeUntilFormatted = ko.computed =>
      au = @absenteeUntil()
      if !au or au.match(/^\s*$/)
        ""
      else
        moment(au).format("MMM D, YYYY")

    @overseas.subscribe (v) =>
      setTimeout((=> @requestingAbsentee(true)), 0) if v

    @optionsErrors = ko.computed =>
      errors = []
      if @chooseParty()
        if !filled(@party()) || (@party() == 'other' and !filled(@otherParty()))
          errors.push("Party preference")

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

      errors

    @optionsInvalid = ko.computed => @optionsErrors().length > 0

  setAbsenteeUntil: (val) ->
    @absenteeUntil(val)
    $("#registration_absentee_until").val(val)

  initAbsenteeUntilSlider: ->
    return if @abstenteeUntilSlider
    rau = $("#registration_absentee_until").val()
    @setAbsenteeUntil(rau)

    days = Math.floor((moment(rau) - moment()) / 86400000)
    @absenteeUntilSlider = $("#absentee_until")
    @absenteeUntilSlider.slider(min: 45, max: 365, value: days, slide: @onAbsenteeUntilSlide)

  onAbsenteeUntilSlide: (e, ui) =>
    val = moment().add('days', ui.value).format("YYYY-MM-DD")
    @setAbsenteeUntil(val)
    true

  initSummaryFields: ->
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

    @summaryParty = ko.computed =>
      if @chooseParty()
        if @party() == 'other'
          @otherParty()
        else
          @party()

  initOathFields: ->
    @infoCorrect  = ko.observable()
    @privacyAgree = ko.observable()

    @oathErrors = ko.computed =>
      errors = []
      errors.push("Confirm that information is correct") unless @infoCorrect()
      errors.push("Agree with privacy terms") unless @privacyAgree()
      errors

    @oathInvalid = ko.computed => @oathErrors().length > 0
