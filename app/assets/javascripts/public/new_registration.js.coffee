window.stepClass = (current, idx, def) ->
  def   = def || 'span2'
  match = if $.isArray(idx) then idx.indexOf(current) > -1 else idx == current
  max   = if $.isArray(idx) then idx[idx.length - 1] else idx
  (if match then 'current ' else if current > max then 'done ' else '') + def

filled = (v) -> v && !v.match(/^\s*$/)
join   = (a, sep) -> $.map(a, (i) -> if filled(i) then i else null).join(sep)


class NewRegistration
  constructor: (initPage = 0) ->
    @oname    = 'registration_request'
    oid       = "##{@oname}"
    @pages    = [ 'eligibility', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]

    overseas  = true # debug

    @eligibilitySection(overseas)
    @identitySection(overseas)
    @addressSection(overseas)
    @optionsSection(overseas)

    # Summary
    @summaryFullName = ko.computed =>
      join([ @firstName(), @middleName(), @lastName(), @suffix() ], ' ')

    @summaryDOB = ko.computed =>
      if filled(@dobMonth()) && filled(@dobDay()) && filled(@dobYear())
        moment([ @dobYear(), parseInt(@dobMonth()) - 1, @dobDay() ]).format("MMMM D, YYYY")

    @summaryAddress1 = ko.computed =>
      if @vvrIsRural()
        @vvrRural()
      else
        join([ join([ @vvrStreetNumber(), @vvrApt() ], '/'), @vvrStreetName(), @vvrStreetType() ], ' ')

    @summaryAddress2 = ko.computed =>
      unless @vvrIsRural()
        join([ @vvrCity(), join([ @vvrState(), join([ @vvrZip5(), @vvrZip4() ], '-') ], ' ') ], ', ')

    @summaryStatus = ko.computed => if @requestingAbsentee() then 'Absentee' else 'In person'


    # Navigation
    @currentPageIdx         = ko.observable(initPage)
    @page                   = ko.computed(=> @pages[@currentPageIdx()])

    $(window).hashchange =>
      hash = location.hash
      newIdx = @pages.indexOf(hash.replace('#', ''))
      newIdx = 0 if newIdx == -1
      @currentPageIdx(newIdx)

  # --- Validation

  eligibilitySection: (overseas) =>
    @isCitizen              = ko.observable()
    @isOldEnough            = ko.observable()
    @residence              = ko.observable(if overseas then 'outside' else 'in')
    @overseas               = ko.computed => @residence() == 'outside'
    @domestic               = ko.computed => !@overseas()
    @rightsWereRevoked      = ko.observable()
    @rightsRevokationReason = ko.observable()
    @rightsWereRestored     = ko.observable()

    @eligibilityValid = ko.computed =>
      @isCitizen() and @isOldEnough() and
        (@rightsWereRevoked() == 'no' or (@rightsRevokationReason() and @rightsWereRestored() == 'yes')) or
        false

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

    @identityValid = ko.computed =>
      filled(@lastName()) and
      filled(@dobYear()) and filled(@dobMonth()) and filled(@dobDay()) and
      filled(@gender()) and (filled(@ssn()) or @noSSN()) or
      false

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
    @vvrCity                = ko.observable()
    @vvrState               = ko.observable()
    @vvrZip5                = ko.observable()
    @vvrZip4                = ko.observable()
    @vvrCountyOrCity        = ko.observable()
    @vvrCountyOrCity.subscribe (coc) => @vvrCity(coc.replace(/\s+city/i, '')) if coc.match(/\s+city/i)
    @vvrOverseasRA          = ko.observable()
    @maAddress1             = ko.observable()
    @maCity                 = ko.observable()
    @maState                = ko.observable()
    @maZip5                 = ko.observable()
    @mauType                = ko.observable()
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
      ( filled(@maAddress1()) and
        filled(@maCity()) and
        filled(@maState()) and
        filled(@maZip5()) )

    @nonUSMAFilled = ko.computed =>
      filled(@mauAddress()) and
      filled(@mauCity()) and
      filled(@mauState()) and
      filled(@mauPostalCode()) and
      filled(@mauCountry())

    @overseasMAFilled = ko.computed =>
      if   @mauType() == 'apo'
      then filled(@mauAPO1()) and filled(@mauAPO2()) and filled(@mauAPOZip5())
      else @nonUSMAFilled()


    @addressesValid = ko.computed =>
      residental =
        if   @vvrIsRural()
        then filled(@vvrRural())
        else filled(@vvrStreetNumber()) and
             filled(@vvrStreetName()) and
             filled(@vvrStreetType()) and
             filled(@vvrCity()) and
             filled(@vvrState()) and
             filled(@vvrZip5()) and
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
             filled(@erStreetType()) and
             filled(@erCity()) and
             filled(@erState()) and
             filled(@erZip5())

      residental and mailing and existing

  optionsSection: (overseas) =>
    @isConfidentialAddress  = ko.observable(false)
    @requestingAbsentee     = ko.observable(overseas)
    @rabElection            = ko.observable()
    @abSendTo               = ko.observable()
    @outsideType            = ko.observable()
    @needsServiceDetails    = ko.computed => @outsideType() && @outsideType().match(/duty/)

  # --- Navigation

  prevPage: => window.history.back()
  nextPage: =>
    newIdx = @currentPageIdx() + 1
    location.hash = @pages[newIdx]

ko.applyBindings(new NewRegistration(0))
