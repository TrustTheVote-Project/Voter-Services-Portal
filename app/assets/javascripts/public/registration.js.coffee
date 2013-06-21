class window.Registration
  constructor: (residence) ->
    @residence  = ko.observable(residence)
    @overseas   = ko.computed => @residence() == 'outside'
    @domestic   = ko.computed => !@overseas()

    @allowInelligibleToCompleteForm = ko.observable($("input#allow_ineligible_to_complete_form").val() == 'true')
    @paperlessSubmission = ko.observable()
    @showAssistantDetails = ko.computed =>
      el = $("input#display_assistant_details")
      if @paperlessSubmission()
        el.attr('data-paperless') == 'true'
      else
        el.attr('data-paper') == 'true'

    @initEligibilityFields()
    @initIdentityFields()
    @initAddressFields()
    @initOptionsFields()
    @initSummaryFields()
    @initOathFields()

  initEligibilityFields: ->
    @citizen                      = ko.observable()
    @oldEnough                    = ko.observable()
    @rightsWereRevoked            = ko.observable()
    @rightsFelony                 = ko.observable()
    @rightsMental                 = ko.observable()
    @rightsFelonyRestored         = ko.observable()
    @rightsMentalRestored         = ko.observable()
    @rightsFelonyRestoredOnMonth  = ko.observable()
    @rightsFelonyRestoredOnYear   = ko.observable()
    @rightsFelonyRestoredOnDay    = ko.observable()
    @rightsMentalRestoredOnMonth  = ko.observable()
    @rightsMentalRestoredOnYear   = ko.observable()
    @rightsMentalRestoredOnDay    = ko.observable()
    @rightsFelonyRestoredIn       = ko.observable()
    @rightsFelonyRestoredInText   = ko.computed => $("#registration_rights_felony_restored_in option[value='#{@rightsFelonyRestoredIn()}']").text()
    @rightsFelonyRestoredOn       = ko.computed => pastDate(@rightsFelonyRestoredOnYear(), @rightsFelonyRestoredOnMonth(), @rightsFelonyRestoredOnDay())
    @rightsMentalRestoredOn       = ko.computed => pastDate(@rightsMentalRestoredOnYear(), @rightsMentalRestoredOnMonth(), @rightsMentalRestoredOnDay())
    @dobYear                      = ko.observable()
    @dobMonth                     = ko.observable()
    @dobDay                       = ko.observable()
    @dob                          = ko.computed => pastDate(@dobYear(), @dobMonth(), @dobDay())
    @ssn                          = ko.observable()
    @noSSN                        = ko.observable()
    @dmvId                        = ko.observable()

    @isEligible = ko.computed =>
      @citizen() == '1' and
      @oldEnough() == '1' and
      !!@dob() and
      !@noSSN() and filled(@ssn()) and
      (@rightsWereRevoked() == '0' or
        ((@rightsFelony() == '1' or @rightsMental() == '1') and
         (@rightsFelony() == '0' or (@rightsFelonyRestored() == '1' and filled(@rightsFelonyRestoredIn()) and !!@rightsFelonyRestoredOn())) and
         (@rightsMental() == '0' or (@rightsMentalRestored() == '1' and !!@rightsMentalRestoredOn()))))

    @eligibilityErrors = ko.computed =>
      errors = []
      errors.push("Citizenship criteria") unless @citizen()
      errors.push("Age criteria") unless @oldEnough()

      errors.push("Voting rights criteria") if !filled(@rightsWereRevoked()) or
        (@rightsWereRevoked() == '1' and
          ((@rightsFelony() != '1' and @rightsMental() != '1') or
           (@rightsFelony() == '1' and (@rightsFelonyRestored() != '1' or !@rightsFelonyRestoredOn())) or
           (@rightsMental() == '1' and (@rightsMentalRestored() != '1' or !@rightsMentalRestoredOn()))))

      errors.push('Date of birth') unless @dob()
      errors.push('Social Security #') if !ssn(@ssn()) and !@noSSN()
      errors

  initIdentityFields: ->
    @firstName              = ko.observable()
    @middleName             = ko.observable()
    @lastName               = ko.observable()
    @suffix                 = ko.observable()
    @gender                 = ko.observable()
    @phone                  = ko.observable()
    @validPhone             = ko.computed => !filled(@phone()) or phone(@phone())
    @email                  = ko.observable()
    @validEmail             = ko.computed => !filled(@email()) or email(@email())

    @identityErrors = ko.computed =>
      errors = []
      errors.push('First name') unless filled(@firstName())
      errors.push('Last name') unless filled(@lastName())
      errors.push('Gender') unless filled(@gender())
      errors.push('Phone number') unless @validPhone()
      errors.push('Email address') unless @validEmail()
      errors

    @identityInvalid = ko.computed => @identityErrors().length > 0

  initAddressFields: ->
    @vvrIsRural             = ko.observable(false)
    @vvrRural               = ko.observable()
    @maIsDifferent          = ko.observable(false)
    @prStatus               = ko.observable()
    @prIsRural              = ko.observable(false)
    @vvrAddress1            = ko.observable()
    @vvrAddress2            = ko.observable()
    # TODO #rework
    # @vvrStreetType          = ko.observable()
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
    @vvrUocavaResidenceUnavailableSince = ko.computed => pastDate(@vvrUocavaResidenceUnavailableSinceYear(), @vvrUocavaResidenceUnavailableSinceMonth(), @vvrUocavaResidenceUnavailableSinceDay())
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
    @prFirstName            = ko.observable()
    @prMiddleName           = ko.observable()
    @prLastName             = ko.observable()
    @prSuffix               = ko.observable()
    @prAddress1             = ko.observable()
    @prAddress2             = ko.observable()
    @prCity                 = ko.observable()
    @prState                = ko.observable()
    @prZip5                 = ko.observable()
    @prZip4                 = ko.observable()
    @prRural                = ko.observable()
    @prCancel               = ko.observable()

    @vvrCountyOrCity.subscribe (v) =>
      if v.match(/\s+city$/i)
        @vvrTown(v.replace(/\s+city$/i, ''))

    @vvrIsRural.subscribe (v) =>
      @maIsDifferent(true) if v

    @domesticMAFilled = ko.computed =>
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
      then filled(@mauAPOAddress1()) and filled(@mauAPO1()) and zip5(@mauAPOZip5())
      else @nonUSMAFilled()

    @addressesErrors = ko.computed =>
      errors = []

      residental =
        if   @vvrIsRural()
        then filled(@vvrRural())
        else filled(@vvrAddress1()) and
             (!@vvrCountySelected() or filled(@vvrTown())) and
             filled(@vvrState()) and
             zip5(@vvrZip5()) and
             filled(@vvrCountyOrCity())

      if @overseas()
        residental = residental and
          filled(@vvrOverseasRA()) and
          (@vvrOverseasRA() == '1' or @vvrUocavaResidenceUnavailableSince())
        mailing = @overseasMAFilled()
      else
        mailing = !@maIsDifferent() or @domesticMAFilled()

      previous =
        filled(@prStatus()) and (
          @prStatus() != '1' or
          filled(@prFirstName()) and
          filled(@prLastName()) and
          @prCancel() and
          if   @prIsRural()
          then filled(@prRural())
          else filled(@prAddress1()) and
               filled(@prState()) and
               filled(@prCity()) and
               zip5(@prZip5())
        )

      errors.push("Registration address") unless residental
      errors.push("Mailing address") unless mailing
      errors.push("Previous registration") unless previous
      errors

    @addressesInvalid = ko.computed => @addressesErrors().length > 0

  initOptionsFields: ->
    @party                  = ko.observable()
    @chooseParty            = ko.observable()
    @otherParty             = ko.observable()

    @caType                 = ko.observable()
    @isConfidentialAddress  = ko.observable()

    @needsAssistance        = ko.observable()

    @requestingAbsentee     = ko.observable()
    @absenteeUntil          = ko.observable()
    @rabElection            = ko.observable()
    @rabElectionName        = ko.observable()
    @rabElectionDate        = ko.observable()
    @outsideType            = ko.observable()
    @needsServiceDetails    = ko.computed => @outsideType() && @outsideType().match(/MerchantMarine/)
    @serviceBranch          = ko.observable()
    @serviceId              = ko.observable()
    @rank                   = ko.observable()

    @residence.subscribe (v) =>
      @requestingAbsentee(v == 'outside')
    @isConfidentialAddress.subscribe (v) =>
      @caType(null) unless v

    @abReason               = ko.observable()
    @abField1               = ko.observable()
    @abField2               = ko.observable()
    @abStreetNumber         = ko.observable()
    @abStreetName           = ko.observable()
    @abStreetType           = ko.observable()
    @abApt                  = ko.observable()
    @abCity                 = ko.observable()
    @abState                = ko.observable()
    @abZip5                 = ko.observable()
    @abZip4                 = ko.observable()
    @abCountry              = ko.observable()
    @abTime1Hour            = ko.observable()
    @abTime1Minute          = ko.observable()
    @abTime2Hour            = ko.observable()
    @abTime2Minute          = ko.observable()

    @abAddressRequired = ko.computed =>
      r = @abReason()
      r == '1A' or
      r == '1B' or
      r == '1E' or
      r == '3A' or r == '3B'

    @abField1Required = ko.computed =>
      r = @abReason()
      r == '1A' or
      r == '1B' or
      r == '1C' or
      r == '1D' or
      r == '1E' or
      r == '2A' or
      r == '2B' or
      r == '3A' or r == '3B' or
      r == '5A' or
      r == '8A'

    @abField2Required = ko.computed =>
      r = @abReason()
      r == '2B' or
      r == '5A'

    @abTimeRangeRequired = ko.computed =>
      @abReason() == '1E'

    @abPartyLookupRequired = ko.computed =>
      @abReason() == '8A'

    @abField1Label = ko.computed =>
      r = @abReason()
      if r == '1A' or r == '1B'
        "Name of school"
      else if r == '1C' or r == '1E'
        "Name of employer or businesss"
      else if r == '1D'
        "Place of travel<br/>VA county/city, state or country"
      else if r == '2A' or r == '2B'
        "Nature of disability or illness"
      else if r == '3A' or r == '3B'
        "Place of confinement"
      else if r == '5A'
        "Religion"
      else if r == '8A'
        "Designated candidate party"

    @abField2Label = ko.computed =>
      r = @abReason()
      if r == '2B'
        "Name of family member"
      else if r == '5A'
        "Nature of obligation"

    @absenteeUntilFormatted = ko.computed =>
      au = @absenteeUntil()
      if !au or au.match(/^\s*$/)
        ""
      else
        moment(au).format("MMM D, YYYY")

    @beOfficial = ko.observable()

    @overseas.subscribe (v) =>
      setTimeout((=> @requestingAbsentee(true)), 0) if v

    @protectedVoterAdditionals = ko.computed =>
      @isConfidentialAddress() and
        (@caType() == 'TSC' or (@domestic() and !@maIsDifferent()))

    @optionsErrors = ko.computed =>
      errors = []
      if @chooseParty()
        if !filled(@party()) || (@party() == 'other' and !filled(@otherParty()))
          errors.push("Party preference")

      if @isConfidentialAddress()
        if !filled(@caType())
          errors.push("Address confidentiality reason")
        else
          if (@overseas() and !@overseasMAFilled()) or (@domestic() and !@domesticMAFilled())
            errors.push("Protected voter mailing address")

      if @requestingAbsentee()
        if @overseas()
          errors.push("Absence type") unless filled(@outsideType())
          errors.push("Service details") if @needsServiceDetails() and (!filled(@serviceId()) || !filled(@rank()))
        else
          if !filled(@rabElection()) or (@rabElection() == 'other' and (!filled(@rabElectionName()) or !filled(@rabElectionDate())))
            errors.push("Election details")

          if !filled(@abReason())
            errors.push("Absence reason")

          if @abAddressRequired() and
            (!filled(@abStreetNumber()) or
            !filled(@abStreetName()) or
            !filled(@abCity()) or
            !filled(@abState()) or
            !zip5(@abZip5()) or
            !filled(@abCountry()))
              errors.push("Address in supporting information")

          if @abTimeRangeRequired() and
            (!filled(@abTime1Hour()) or
            !filled(@abTime1Minute()) or
            !filled(@abTime2Hour()) or
            !filled(@abTime2Minute()))
              errors.push("Time range in supporting information")

          if @abField1Required() and
            !filled(@abField1())
              errors.push(@abField1Label())

          if @abField2Required() and
            !filled(@abField2())
              errors.push(@abField2Label())

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
      valueOrUnspecified(join([ @firstName(), @middleName(), @lastName(), @suffix() ], ' '))

    @summaryEligibility = ko.computed =>
      items = []
      if @citizen()
        items.push "U.S. citizen"
      else
        items.push "Not a U.S. citizen"

      if @domestic()
        items.push "VA resident"

      if @oldEnough()
        items.push "Over 18 by next election"
      else
        items.push "Not over 18 by next election"

      items.join(', ')

    @summaryGender    = ko.computed => valueOrUnspecified(@gender())

    @summaryVotingRights = ko.computed =>
      if !filled(@rightsWereRevoked())
        "Unspecified"
      else if @rightsWereRevoked() == '0'
        "Not revoked"
      else
        lines = [ ]
        if (@rightsFelony() == '1' and @rightsFelonyRestored() != '1') or
           (@rightsMental() == '1' and @rightsMentalRestored() != '1')
          lines.push "Revoked"
        else
          lines.push "Restored"

        lines.join "<br/>"
    @summarySSN = ko.computed =>
      if @noSSN() || !filled(@ssn())
        "none"
      else
        @ssn()
    @summaryDMVID = ko.computed =>
      if !filled(@dmvId())
        "none"
      else
        @dmvId()
    @summaryDOB = ko.computed =>
      if filled(@dobMonth()) && filled(@dobDay()) && filled(@dobYear())
        moment([ @dobYear(), parseInt(@dobMonth()) - 1, @dobDay() ]).format("MMMM D, YYYY")
      else
        "Unspecified"

    @summaryRegistrationAddress = ko.computed =>
      address = if @vvrIsRural()
          @vvrRural()
        else
          join([ @vvrAddress1(), @vvrAddress2() ], ' ') + "<br/>" +
          join([ @vvrTown(), join([ @vvrState(), join([ @vvrZip5(), @vvrZip4() ], '-') ], ' ') ], ', ')

      if @overseas()
        lines = [ address ]
        if @vvrOverseasRA() == '0'
          lines.push "Last day available: #{moment(@vvrUocavaResidenceUnavailableSince()).format("MMMM Do, YYYY")}"
        lines.join "<br/>"
      else
        address

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


    @summaryExistingRegistration = ko.computed =>
      if @prStatus() != '1'
        "Not currently registered in another state"
      else
        lines = []

        lines.push valueOrUnspecified(join([ @prFirstName(), @prMiddleName(), @prLastName(), @prSuffix() ], ' '))

        if @prIsRural()
          lines.push @prRural()
        else
          lines.push join([ @prAddress1(), @prAddress2() ], ' ') + "<br/>" +
            join([ @prCity(), join([ @prState(), join([ @prZip5(), @prZip4() ], '-') ], ' ') ], ', ')
        if @prCancel()
          lines.push "Authorized cancelation"

        lines.join "<br/>"

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
        if @maIsDifferent() or @isConfidentialAddress()
          @summaryDomesticMailingAddress()
        else
          @summaryRegistrationAddress()

    @summaryAbsenteeRequest = ko.computed =>
      lines = []

      if @overseas()
        lines = []
        type = $("label", $(".overseas_outside_type input[value='#{@outsideType()}']").parent()).text()
        lines.push "Reason: #{type}"

        if @needsServiceDetails()
          branch = $("#registration_service_branch option[value='#{@serviceBranch()}']").text()
          lines.push "Service details: #{branch} - #{@serviceId()} - #{@rank()}"

      else
        # domestic
        if @rabElection() != 'other'
          election = @rabElection()
        else
          election = "#{@rabElectionName()} held on #{@rabElectionDate()}"
        lines.push "Applying to vote abstentee in #{election}"

        if filled(@abReason())
          lines.push "Reason: #{$("#registration_ab_reason option[value='#{@abReason()}']").text()}"

        if @abField1Required() and filled(@abField1())
          v = @abField1()
          if @abPartyLookupRequired()
            v = $("#registration_ab_field_1 option[value='#{v}']").text()
          lines.push "#{@abField1Label()}: #{v}"
        if @abField2Required() and filled(@abField2())
          lines.push "#{@abField2Label()}: #{@abField2()}"
        if @abTimeRangeRequired()
          h1 = @abTime1Hour()
          m1 = @abTime1Minute()
          h2 = @abTime2Hour()
          m2 = @abTime2Minute()
          lines.push "Time: #{time(h1, m1)} - #{time(h2, m2)}"
        if @abAddressRequired()
          lines.push join([ @abStreetNumber(), @abStreetName(), @abStreetType(), (if filled(@abApt()) then "##{@abApt()}" else null) ], ' ') + "<br/>" +
            join([ @abCity(), join([ @abState(), join([ @abZip5(), @abZip4() ], '-'), @abCountry() ], ' ') ], ', ')

      lines.join "<br/>"

    @showingPartySummary = ko.computed =>
      @requestingAbsentee() and @overseas() and @summaryParty()

    @summaryParty = ko.computed =>
      if @chooseParty()
        if @party() == 'other'
          @otherParty()
        else
          @party()
      else
        null

    @summaryElection = ko.computed =>
      if @rabElection() == 'other'
        "#{@rabElectionName()} on #{@rabElectionDate()}"
      else
        v = @rabElection()
        $("#registration_rab_election option[value='#{v}']").text()

  initOathFields: ->
    @infoCorrect  = ko.observable()
    @asFirstName  = ko.observable()
    @asMiddleName = ko.observable()
    @asLastName   = ko.observable()
    @asSuffix     = ko.observable()
    @asAddress1   = ko.observable()
    @asAddress2   = ko.observable()
    @asCity       = ko.observable()
    @asState      = ko.observable()
    @asZip5       = ko.observable()
    @asZip4       = ko.observable()

    @oathErrors = ko.computed =>
      errors = []
      errors.push("Confirm that information is correct") unless @infoCorrect()
      errors.push("Social Security #") if !ssn(@ssn()) and !@noSSN()

      unless @paperlessSubmission()
        fn = filled(@asFirstName())
        ln = filled(@asLastName())
        a  = filled(@asAddress1())
        c  = filled(@asCity())
        s  = filled(@asState())

        reqAInfo = fn || ln || a || c || s ||
                   filled(@asMiddleName()) ||
                   filled(@asSuffix()) ||
                   filled(@asAddress2()) ||
                   filled(@asZip5()) ||
                   filled(@asZip4())

        if reqAInfo && (!fn || !ln)
          errors.push("Assistant name")

        if reqAInfo && (!a || !c || !s || !zip5(@asZip5()))
          errors.push("Assistant address")

      errors

    @oathInvalid = ko.computed => @oathErrors().length > 0

  checkEligibility: (_, e) =>
    return if $(e.target).hasClass('disabled')
    if @isEligible()
      @lookupRecord(_, e)
    else
      if @allowInelligibleToCompleteForm()
        @gotoPage('identity')
      else
        @gotoPage('ineligible')

  lookupRecord: (_, e) =>
    return if $(e.target).hasClass('disabled')
    @page('lookup')

    $.getJSON '/lookup/registration', { record: {
        eligible_citizen:             @citizen(),
        eligible_18_next_election:    @oldEnough(),
        eligible_revoked_felony:      @rightsFelony(),
        eligible_revoked_competence:  @rightsMental(),
        dob:                          "#{@dobMonth()}/#{@dobDay()}/#{@dobYear()}",
        ssn:                          @ssn(),
        dmv_id:                       @dmvId()
      }}, (data) =>
        if data.registered
          location.hash = "registered_info"
        else
          @paperlessSubmission(data.dmv_match)
          if @paperlessSubmission()
            a = data.address
            @vvrAddress1(a.address_1)
            @vvrAddress2(a.address_2)
            @vvrCountyOrCity(a.county_or_city)
            @vvrZip5(a.zip5)
          location.hash = 'identity'

