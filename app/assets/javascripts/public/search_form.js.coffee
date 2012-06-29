class SearchForm
  constructor: ->
    @voterId    = ko.observable()
    @locality   = ko.observable()
    @firstName  = ko.observable()
    @lastName   = ko.observable()
    @ssn4       = ko.observable()
    @swear      = ko.observable()

    @dobDay     = ko.observable()
    @dobMonth   = ko.observable()
    @dobYear    = ko.observable()

    @dob = ko.computed =>
      dte = date(@dobYear(), @dobMonth(), @dobDay())
      (dte and dte.format("YYYY-M-D")) or ""

    @errors = ko.computed =>
      errors = []

      unless @swear()
        errors.push("Affirmation")

      unless filled(@firstName())
        errors.push("First name")
      unless filled(@lastName())
        errors.push("Last name")
      unless filled(@locality())
        errors.push("Locality")

      if !filled(@voterId()) && !filled(@ssn4()) && !filled(@dob())
        errors.push("Voter ID or SSN and Date of birth")
      else
        if filled(@voterId())
          errors.push("Voter ID (16 digits)") if !voterId(@voterId())
        else
          errors.push("Date of birth") if !filled(@dob())
          errors.push("Social security number") if !filled(@ssn4())

      errors

    @invalid = ko.computed => @errors().length > 0
    new Popover('#new_search_query .next.btn', @errors)

  submit: =>
    return if @invalid()
    $("form#new_search_query")[0].submit()

$ ->
  if $("form#new_search_query").length > 0
    ko.applyBindings(new SearchForm())
