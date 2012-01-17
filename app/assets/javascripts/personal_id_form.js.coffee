class PersonalIdForm
  constructor: ->
    @form       = $("form#new_search_query")
    @voterId    = $("#search_query_voter_id")
    @firstName  = $("#search_query_first_name")
    @lastName   = $("#search_query_last_name")
    @ssn4       = $("#search_query_ssn4")
    @btn        = $(".btn[name='commit']")

    $("input", @form).change(@onFormChange).keyup(@onFormChange)

  isValidForm: ->
    @filled(@voterId) or
      @filled(@firstName) and
      @filled(@lastName) and
      @filled(@ssn4, min: 4, max: 4)

  filled: (el, options = {}) ->
    v = $(el).val()

    !v.match(/^\s*$/) and
    (!(max = options['max']) or v.length <= max) and
    (!(min = options['min']) or v.length >= min)

  onFormChange: =>
    if @isValidForm()
      @btn.removeAttr('disabled')
    else
      @btn.attr('disabled', 'true')

$ ->
  window.fr = new PersonalIdForm
