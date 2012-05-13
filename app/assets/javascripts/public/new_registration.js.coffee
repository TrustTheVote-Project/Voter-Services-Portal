window.stepClass = (current, idx, def) ->
  def   = def || 'span2'
  match = if $.isArray(idx) then idx.indexOf(current) > -1 else idx == current
  max   = if $.isArray(idx) then idx[idx.length - 1] else idx
  (if match then 'current ' else if current > max then 'done ' else '') + def

class NewRegistration
  constructor: (initPage = 0) ->
    @pages = [ 'eligibility', 'identity', 'address', 'options', 'confirm', 'oath', 'download', 'congratulations' ]

    # Eligibility
    @rightsWereRevoked      = ko.observable()
    @rightsRevokationReason = ko.observable()
    @rightsWereRestored     = ko.observable()

    # Addresses
    @vvrIsRural             = ko.observable(false)
    @maIsSame               = ko.observable('yes')
    @hasExistingReg         = ko.observable('no')
    @erIsRural              = ko.observable(false)

    # Options
    @isConfidentialAddress  = ko.observable(false)
    @requestingAbsentee     = ko.observable(false)
    @rabElection            = ko.observable()
    @abSendTo               = ko.observable()

    # Navigation
    @currentPageIdx         = ko.observable(initPage)
    @page                   = ko.computed(=> @pages[@currentPageIdx()])

  # Navigation
  prevPage: => @currentPageIdx(@currentPageIdx() - 1)
  nextPage: => @currentPageIdx((@currentPageIdx() + 1) % @pages.length)

ko.applyBindings(new NewRegistration(0))
