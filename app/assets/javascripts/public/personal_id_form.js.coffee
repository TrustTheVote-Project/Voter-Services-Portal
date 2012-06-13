class PersonalIdForm
  constructor: ->
    @voterId    = ko.observable()
    @locality   = ko.observable()
    @lastName   = ko.observable()
    @ssn4       = ko.observable()
    @swear      = ko.observable()

    @errors = ko.computed =>
      errors = []

      unless @swear()
        errors.push("Affirmation")

      if filled(@voterId())
        errors.push("Voter ID (16 digits)") if !voterId(@voterId())
      else
        errors.push("Locality") if !filled(@locality())
        errors.push("Last name") if !filled(@lastName())
        errors.push("Social security number") if !filled(@ssn4())

      errors

    @invalid = ko.computed => @errors().length > 0
    new Popover('#new_search_query .next.btn', @errors)

$ ->
  if $("form#new_search_query").length > 0
    ko.applyBindings(new PersonalIdForm())
