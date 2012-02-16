Forms = window.Forms = {}

# Status of the field that appears next to the field given.
# Can take unknown / valid / invalid states and displays either
# none, valid or invalid messages given.
#
class Forms.FieldStatus
  constructor: (@input) ->
    @hint = $("<span class='help-inline'>").hide()
    @input.append(@hint)
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


# Simple block visibility toggling field.
# When checked, the block is visible, otherwise -- not.
class Forms.BlockToggleField
  constructor: (id, block_id) ->
    @el = $(id)
    @block = $(block_id)

    # If it's a radio-button, monitor whole group, not this one only
    # to be able to catch unchecks.
    if @el.attr('type') == 'radio'
      $("input[name='" + @el.attr('name') + "']").change(@onChange)
    else
      @el.change(@onChange)

    @onChange()

  onChange: (e) =>
    if @el.is(':checked')
      @block.show()
    else
      @block.hide()

# Abstract required field that supports listeners
# and optional status field.
class Forms.AbstractRequiredField
  constructor: (@options = {}) ->
    @listeners = []
    @dep = @options['unless']

    # Register ourselves as a listener to dependency changes
    @dep.addListener(this) if @dep

  # Call this method when you know the of an element you want to append
  # your status label to.
  appendStatusTo: (id) ->
    @status = new Forms.FieldStatus(id) unless @options['status'] == false

  addListener: (l) ->
    @listeners.push(l)

  validate: ->
    console.log('Implement')
    return null

  isValid: ->
    @validate() == null

  onFocus: =>
    @status.untouched()

  onChange: =>
    @status.setState(@validate()) if @status
    l.onChange() for l in @listeners


# Single required field that can have or not have a status next to it
# Options are:
#
#   status - (true / false; default 'true') controls if the status appears.
#   max    - (integer) maximum length of the value
#   min    - (integer) minimum length of the value
#   date   - (boolean; default false) TRUE to indicate that the field is
#             a date
#   skip_validation_if - (function) return TRUE to skip validating the
#             field and report it as valid.
#
class Forms.RequiredTextField extends Forms.AbstractRequiredField
  constructor: (id, @options = {}) ->
    super @options

    @field = $(id)
    @field.focus(@onFocus) if @status
    @field.change(@onChange).blur(@onChange).keyup(@onKeyup)

    @appendStatusTo @field.parent()

  validate: ->
    # Skip validation if there's a pre-condition and it results in TRUE
    call = @options['skip_validation_if']
    return null if call and call()

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

  onKeyup: =>
    # Don't check if we just moved into the field via tabbing
    return if @field.val().match(/^$/)
    @onChange()


# Required date field that supports the validation of all three
# selection boxes filled.
class Forms.RequiredDateField extends Forms.AbstractRequiredField
  constructor: (id) ->
    super

    @year  = $(id + "_1i")
    @month = $(id + "_2i")
    @date  = $(id + "_3i")

    fields = $("select[id*='" + id.replace('#', '') + "_']")
    fields.focus(@onFocus) if @status
    fields.change(@onChange).blur(@onChange)

    @appendStatusTo @year.parent()

  validate: ->
    blank = /^\s*$/

    if @year.val().match(blank) or @month.val().match(blank) or @date.val().match(blank)
      return "Cannot be blank"

    return null

# A single section of a form with "Next" and "Back" buttons.
class Forms.Section
  constructor: (id, navigationListener) ->
    @el = $(id)
    @complete = false

    # Back button
    @btnBack = $('.btn.back', @el).click (e) ->
      e.preventDefault()
      navigationListener.onPrevSection()

    # Next button
    @btnNext = $('.btn.next', @el).click (e) =>
      e.preventDefault()
      navigationListener.onNextSection() if @complete

    @updateButton()
    $('input, select, textarea', @el).change(@updateButton).keyup(@updateButton)

  updateButton: =>
    if @complete = @isComplete()
      @btnNext.removeClass('disabled')
    else
      @btnNext.addClass('disabled')

  isComplete: -> true

  hide: => @el.hide()
  show: => @el.show()
  name: => @el.attr('id')

  filled: (el) -> el.val().match(/^[^\s]+$/)
  checked: (el) -> el.is(":checked")


# Step indicator
class Forms.StepIndicator
  constructor: (id) ->
    @el       = $(id)
    @allSteps = $("tr[id*='step_']", @el)

  setCurrent: (name) ->
    @allSteps.removeClass 'current'
    $("#step_" + name).addClass 'current'


# A form with multiple sections.
class Forms.MultiSectionForm
  constructor: (@sections = [], @indicator = null) ->
    @currentSection = null
    @currentSectionIndex = -1

    # Start from the first section if the list is given
    @onNextSection() if @sections.length > 0

  onPrevSection: =>
    unless @currentSectionIndex <= 0
      @navigate -1

  onNextSection: =>
    if @currentSectionIndex == @sections.length - 1
      @onSubmit()
    else
      @navigate 1

  navigate: (d) ->
    @currentSection.hide() if @currentSection
    @currentSectionIndex += d
    @currentSection = @sections[@currentSectionIndex]
    @currentSection.show()

    # Mark current section
    @indicator.setCurrent @currentSection.name() if @indicator


  onSubmit: =>
    console.log('Implement submission')
