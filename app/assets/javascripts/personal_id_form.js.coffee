# Status of the field that appears next to the field given.
# Can take unknown / valid / invalid states and displays either
# none, valid or invalid messages given.
#
class FieldStatus
  constructor: (@input) ->
    @hint = $("<span class='help-inline'>").hide()
    @input.after(@hint)
    @untouched()

  untouched: -> @setState(null)

  setState: (s) ->
    @state = s
    @updateUI()

  updateUI: ->
    if @state == null
      @hint.text("").removeClass('valid').removeClass('invalid').hide()
    else if @state == true
      @hint.text("").addClass('valid').show()
    else
      @hint.html(@state).addClass('invalid').show()


# Single required field that can have or not have a status next to it
# Options are:
# 
#   status - (true / false; default 'true') controls if the status appears.
#   max    - (integer) maximum length of the value
#   min    - (integer) minimum length of the value
#
class RequiredField
  constructor: (id, @options = {}) ->
    @field = $(id)
    @listeners = []
    @status = new FieldStatus(@field) unless @options['status'] == false
    @dep = @options['unless']

    if @status
      @field.focus(@onFocus)

    # Watch for changes
    @field.change(@onChange).blur(@onChange).keyup(@onKeyup)

    # Register ourselves as a listener to dependency changes
    @dep.addListener(this) if @dep

  addListener: (l) ->
    @listeners.push(l)

  validate: ->
    v = @field.val()

    # If there's a dependent field that can be filled instead of this
    # and it's valid, this one is considered valid as well.
    return null if (dep = @options['unless']) and dep.isValid()
    
    if v.match(/^\s*$/)
      return "Cannot be blank"
    else if (max = @options['max']) and v.length > max
      return "Maximum " + max + " digits please"
    else if (min = @options['min']) and v.length < min
      return "Minimum " + min + " digits please"

    return null

  isValid: ->
    @validate() == null

  onKeyup: =>
    # Don't check if we just moved into the field via tabbing
    return if @field.val().match(/^$/)
    @onChange()

  onFocus: =>
    @status.untouched()

  onChange: =>
    @status.setState(@validate()) if @status
    l.onChange() for l in @listeners


# Personal ID form
#
class PersonalIdForm
  constructor: ->
    @form       = $("form#new_search_query")
    @voterId    = new RequiredField("#search_query_voter_id", status: false)
    @firstName  = new RequiredField("#search_query_first_name", unless: @voterId)
    @lastName   = new RequiredField("#search_query_last_name", unless: @voterId)
    @ssn4       = new RequiredField("#search_query_ssn4", min: 4, max: 4, unless: @voterId)
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
