Forms = window.Forms = {}

# Status of the field that appears next to the field given.
# Can take unknown / valid / invalid states and displays either
# none, valid or invalid messages given.
#
class Forms.FieldStatus
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


# Single required field that can have or not have a status next to it
# Options are:
# 
#   status - (true / false; default 'true') controls if the status appears.
#   max    - (integer) maximum length of the value
#   min    - (integer) minimum length of the value
#
class Forms.RequiredField
  constructor: (id, @options = {}) ->
    @field = $(id)
    @listeners = []
    @status = new Forms.FieldStatus(@field) unless @options['status'] == false
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

# A single section of a form with "Next" and "Back" buttons.
class Forms.Section
  constructor: (id, navigationListener) ->
    @el = $(id)

    # Back button
    @btnBack = $('.btn.back', @el).click (e) ->
      e.preventDefault()
      navigationListener.onPrevSection()

    # Next button
    @btnNext = $('.btn.next', @el).click (e) ->
      e.preventDefault()
      navigationListener.onNextSection()

    @updateButton()
    $('input, select', @el).change(@updateButton).keyup(@updateButton)

  updateButton: =>
    if @isComplete()
      @btnNext.removeAttr('disabled')
    else
      @btnNext.attr('disabled', 'disabled')

  isComplete: -> true

  hide: => @el.hide()
  show: => @el.show()

# A form with multiple sections.
class Forms.MultiSectionForm
  constructor: (@sections = []) ->
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


  onSubmit: =>
    console.log('Implement submission')
