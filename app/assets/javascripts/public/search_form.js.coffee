window.ssn4OrVoterId = (s) -> filled($("#search_query_voter_id").val()) || (filled(s) && s.replace(/[^\d]/g, '').match(/^\d{4}$/))

class SearchForm
  constructor: ->
    @lookupType = ko.observable('ssn4')
    @voterId    = ko.observable()
    @locality   = ko.observable()
    @firstName  = ko.observable()
    @lastName   = ko.observable()
    @ssn4       = ko.observable()
    @swear      = ko.observable()

    @dobDay     = ko.observable()
    @dobMonth   = ko.observable()
    @dobYear    = ko.observable()

    @currentPageIdx = ko.observable(null)

    @dob = ko.computed => pastDate(@dobYear(), @dobMonth(), @dobDay())

    @errors = ko.computed =>
      errors = []

      unless filled(@locality())
        errors.push("Locality")

      if @lookupType() == 'ssn4'
        unless filled(@firstName())
          errors.push("First name")
        unless filled(@lastName())
          errors.push("Last name")
        unless present(@dob())
          errors.push("Date of birth")
        unless filled(@ssn4())
          errors.push("SSN4")
      else
        unless filled(@voterId())
          errors.push("Voter ID")

      unless @swear()
        errors.push("Affirmation")

      errors

    @invalid = ko.computed => @errors().length > 0
    new Popover('#new_search_query .next.btn', @errors)

  submit: =>
    return if @invalid()
    $("form#new_search_query")[0].submit()

$ ->
  if $("form#new_search_query").length > 0
    ko.applyBindings(new SearchForm())
