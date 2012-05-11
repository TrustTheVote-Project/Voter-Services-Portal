class PersonalInfoSection extends Forms.Section
  constructor: (navigationListener) ->
    @location_city    = $('#absentee_status_request_location_type_city')
    @location_county  = $('#absentee_status_request_location_type_county')
    @location_name    = new RequiredTextField('#absentee_status_request_location_name')
    super 'fieldset#personal_info', navigationListener

  isComplete: =>
    (@location_city.is(':checked') or @location_county.is(':checked')) and
    @location_name.isValid()

class ElectionSection extends Forms.Section
  constructor: (navigationListener) ->
    super 'fieldset#election', navigationListener

  isComplete: ->
    $("form input:checked[name='absentee_status_request[vote_in]']").length > 0

class Form extends Forms.MultiSectionForm
  constructor: ->
    super [ new PersonalInfoSection(this), @sections.push(new ElectionSection(this)) ]

  onSubmit: =>
    alert('Submitting request')

$ ->
  return unless $('#request_absentee_status').length > 0
  new Form
