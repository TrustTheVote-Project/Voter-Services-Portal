# Personal ID form
#
class PersonalIdForm
  constructor: ->
    @form       = $("form#new_search_query")
    @voterId    = new RequiredTextField("#search_query_voter_id", status: false)
    @firstName  = new RequiredTextField("#search_query_first_name", unless: @voterId)
    @lastName   = new RequiredTextField("#search_query_last_name", unless: @voterId)
    @ssn4       = new RequiredTextField("#search_query_ssn4", min: 4, max: 4, unless: @voterId)
    @btn        = $(".btn[name='commit']")

    $("input", @form).change(@onFormChange).keyup(@onFormChange)

  isValidForm: ->
    @voterId.isValid() or
      @firstName.isValid() and
      @lastName.isValid() and
      @ssn4.isValid()

  onFormChange: =>
    if @isValidForm()
      @btn.removeAttr('disabled')
    else
      @btn.attr('disabled', 'true')

$ ->
  if $("form#new_search_query").length > 0
    window.fr = new PersonalIdForm
