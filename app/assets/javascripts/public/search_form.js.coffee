class SearchForm
  constructor: ->
    @lookupType = ko.observable()
    @voterId    = ko.observable()
    @locality   = ko.observable()
    @firstName  = ko.observable()
    @lastName   = ko.observable()
    @ssn4       = ko.observable()
    @swear      = ko.observable()

    @dobDay     = ko.observable()
    @dobMonth   = ko.observable()
    @dobYear    = ko.observable()
    @dateOfBirthDay     = ko.observable()
    @dateOfBirthMonth   = ko.observable()
    @dateOfBirthYear    = ko.observable()


    @streetNumber     = ko.observable()
    @streetName       = ko.observable()
    @streetType       = ko.observable()
    @vvrAddress1     = ko.observable()
    @vvrTown       = ko.observable()
    @vvrZip5       = ko.observable()
    @idDocumentNumber = ko.observable()
    @idDocumentType   = ko.observable()
    
    @currentPageIdx = ko.observable(null)

    @dob = ko.computed => pastDate(@dobYear(), @dobMonth(), @dobDay())
    @dateOfBirth = ko.computed => pastDate(@dateOfBirthYear(), @dateOfBirthMonth(), @dateOfBirthDay())

    @errors = ko.computed =>
      errors = []

      if gon.lookup_service_config.id_and_locality_style
        unless filled(@locality())
          errors.push("Locality")

        unless present(@dob())
          errors.push("Date of birth")

        if @lookupType() == 'ssn4'
          unless filled(@firstName())
            errors.push("Given name")
          unless filled(@lastName())
            errors.push("Surname (last name)")
          unless ssn4(@ssn4())
            errors.push("SSN4")
        else
          unless voterId(@voterId())
            errors.push("Voter ID")

        unless @swear()
          errors.push("Affirmation")
      else
        if gon.lookup_service_config.first_name
          unless filled(@firstName())
            errors.push("Given Name")
        if gon.lookup_service_config.last_name
          unless filled(@lastName())
            errors.push("Surname (Last Name)")
        if gon.lookup_service_config.date_of_birth
          unless present(@dateOfBirth())
            errors.push("Date Of Birth")          
        if gon.lookup_service_config.street_name
          unless filled(@streetName())
            errors.push("Street Name")
        if gon.lookup_service_config.street_number
          unless filled(@streetNumber())
            errors.push("Street Number")
        if gon.lookup_service_config.street_type
          unless filled(@streetType())
            errors.push("Street Type")
        if gon.lookup_service_config.vvr_address_1
          unless filled(@vvrAddress1())
            errors.push("Address")
        if gon.lookup_service_config.vvr_town
          unless filled(@vvrTown())
            errors.push("Town Name")
        if gon.lookup_service_config.vvr_zip5
          unless present(@vvrZip5())
            errors.push("Zip Code")
        if gon.lookup_service_config.identification_document
          unless present(@idDocumentNumber())
            errors.push("ID Document Number")
          unless present(@idDocumentType())
            errors.push("ID Document Type")
        
      errors

    @invalid = ko.computed => @errors().length > 0
    new Popover('#new_search_query .next.bt', @errors)

  submit: =>
    return if @invalid()
    $("form#new_search_query")[0].submit()

$ ->
  if $("form#new_search_query").length > 0
    ko.applyBindings(new SearchForm())
