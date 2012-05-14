window.stepClass = (current, idx, def) ->
  def   = def || 'span2'
  match = if $.isArray(idx) then idx.indexOf(current) > -1 else idx == current
  max   = if $.isArray(idx) then idx[idx.length - 1] else idx
  (if match then 'current ' else if current > max then 'done ' else '') + def

filled = (v) -> v && !v.match(/^\s*$/)
join   = (a, sep) -> $.map(a, (i) -> if filled(i) then i else null).join(sep)

class NewRegistration
  constructor: (initPage = 0) ->
    @pages = [ 'eligibility', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]

    # Eligibility
    @rightsWereRevoked      = ko.observable()
    @rightsRevokationReason = ko.observable()
    @rightsWereRestored     = ko.observable()

    # Identity
    @firstName              = ko.observable()
    @middleName             = ko.observable()
    @lastName               = ko.observable()
    @suffix                 = ko.observable()
    @dobYear                = ko.observable()
    @dobMonth               = ko.observable()
    @dobDay                 = ko.observable()
    @gender                 = ko.observable()
    @ssn                    = ko.observable()
    @phone                  = ko.observable()
    @email                  = ko.observable()

    # Addresses
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

    # Options
    @isConfidentialAddress  = ko.observable(false)
    @requestingAbsentee     = ko.observable(false)
    @rabElection            = ko.observable()
    @abSendTo               = ko.observable()

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

  # Navigation
  prevPage: => @currentPageIdx(@currentPageIdx() - 1)
  nextPage: => @currentPageIdx((@currentPageIdx() + 1) % @pages.length)

ko.applyBindings(new NewRegistration(0))
