class Section
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

class MultiSectionForm
  constructor: ->
    @sections = []
    @currentSection = null
    @currentSectionIndex = -1

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
    @form[0].submit()

class PersonalInfoSection extends Section
  constructor: (navigationListener) ->
    @location_city    = $('#absentee_status_request_location_type_city')
    @location_county  = $('#absentee_status_request_location_type_county')
    @location_name    = new RequiredField('#absentee_status_request_location_name')
    super 'fieldset#personal_info', navigationListener

  isComplete: =>
    (@location_city.is(':checked') or @location_county.is(':checked')) and
    @location_name.isValid()

class ElectionSection extends Section
  constructor: (navigationListener) ->
    super 'fieldset#election', navigationListener

  isComplete: ->
    $("form input:checked[name='absentee_status_request[vote_in]']").length > 0

class Form extends MultiSectionForm
  constructor: ->
    super
    @sections.push(new PersonalInfoSection(this))
    @sections.push(new ElectionSection(this))
    @onNextSection()

  onSubmit: =>
    alert('Submitting request')

$ ->
  return unless $('#request_absentee_status').length > 0
  new Form
