window.present = (v) ->
  if typeof(v) == 'string'
    filled(v)
  else if v == null
    false
  else if typeof(v) == 'object'
    if v.length then v.length > 0 else !!(v)
  else if typeof(v) == 'number'
    true
  else
    !!(v)

window.dmvIdRegexp = new RegExp("^[0-9a-z]{#{gon.state_id_length_min},#{gon.state_id_length_max}}$", 'i')

window.filled  = (v) -> !!v && !v.match(/^\s*$/)
window.join    = (a, sep) -> $.map(a, (i) -> if filled(i) then i else null).join(sep)
window.zip5    = (v) -> filled(v) && v.match(/^\d{5}$/)
window.caPostalCode = (v) -> filled(v) && v.match(/^[A-Z]\d[A-Z]\s?\d[A-Z]\d$/)
window.caStreetName = (v) -> filled(v) && v.match(/^[a-zA-Z0-9 àâäèéêëîïôœùûüÿçÀÂÄÈÉÊËÎÏÔŒÙÛÜŸÇ\-\.]*$/i)
window.caStreetNumber = (v) -> filled(v) && v.match(/^[\d\-a-zA-Z]*$/i)
window.ssn     = (v) -> filled(v) && v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){9}$/)
window.ssn4    = (s) -> filled(s) && s.match(/^\d{4}$/)
window.voterId = (s) -> filled(s) && s.match(/^\d{9}$/)
window.isDmvId = (s) -> filled(s) && s.replace(/[ \-]/g, '').match(window.dmvIdRegexp)
window.yesNo   = (v) -> if v == '1' then "Yes" else "No"
window.valueOrUnspecified = (v) -> if filled(v) then v else "Unspecified"
window.time = (h, m) -> moment("#{h}:#{m}", "HH:mm").format("h:mm A")

window.date = (y, m, d) ->
  str = "#{y}-#{m}-#{d}"
  dte = moment(str, "YYYY-M-D")
  if dte.format("YYYY-M-D") == str then dte else false

window.dateInRange = (y, m, d, min, max) ->
  dte = date(y, m, d)
  if dte and (!min or dte.diff(min) > 0) and (!max or dte.diff(max) < 0) then dte else false

window.pastDate = (y, m, d) ->
  dateInRange(y, m, d, false, new Date())

window.phone  = (v) -> v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){10}$/)
window.email  = (v) -> v.match(/^\S+@\S+\.\S+$/)

window.stepClass = (current, idx, def) ->
  def = def || 'span2'
  if current == idx
    "current #{def}"
  else if current > idx
    "done #{def}"
  else
    def

# Value handler that respects the existing value
ko.bindingHandlers.valueWithInit = {
  init: (element, valueAccessor, allBindingsAccessor, context) ->
    property = valueAccessor()
    value = $(element).val()

    ko.bindingHandlers.value.init(element, valueAccessor, allBindingsAccessor, context)
    property(value)

  update: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    ko.bindingHandlers.value.update(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext)
}

ko.bindingHandlers.checkedWithInit = {
  init: (element, valueAccessor, allBindingsAccessor, context) ->
    property = valueAccessor()
    el = $(element)
    checked = el.is(':checked')
    value   = el.val()

    ko.bindingHandlers.checked.init(element, valueAccessor, allBindingsAccessor, context)
    if checked
      if el.is(":checkbox")
        property(checked)
      else
        property(value)

  update: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    ko.bindingHandlers.checked.update(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext)
}

# Value handler that hides / shows the section depending on
# the field value.
ko.bindingHandlers.vis = {
  update: (element, valueAccessor) ->
    value = ko.utils.unwrapObservable(valueAccessor())
    isCurrentlyVisible = !(element.style.display == "none")
    if value && !isCurrentlyVisible
      element.style.display = "block"
    else if !value && isCurrentlyVisible
      element.style.display = "none"
}

ko.bindingHandlers.instantValidation = {
  init: (element, valueAccessor, allBindingsAccessor, viewModel) =>
    options    = valueAccessor()
    accessor   = options.accessor

    toggleElement = $(element).is(':checkbox, :radio')
    event = if toggleElement then 'click' else 'blur'

    newValueAccessor = => viewModel[accessor]
    handler = if toggleElement then ko.bindingHandlers.checkedWithInit else ko.bindingHandlers.valueWithInit
    handler.init(element, newValueAccessor, allBindingsAccessor, viewModel)

    validate = =>
      $(element).attr('data-visited', true)
      ko.bindingHandlers.instantValidation.validate(element, valueAccessor, allBindingsAccessor, viewModel)

    visit = (e) -> $(this).attr('data-visited', true)

    $(element).on('keyup', visit).on('change', visit).on('blur', validate).on('validate', validate)

  validate: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    
    options    = valueAccessor()
    attribute  = options.attribute || options.accessor
    validation = options.validation || 'present'
    unlessAttr = options.unless
    $e         = $(element)
    $p         = $e.parent()

    # make sure the user visited the field before validation
    return unless $e.is('[data-visited]')

    if options.complex
      $e.attr('data-touched', true)
      allCount = $p.children('[data-bind]').length
      touchedCount = $p.children('[data-touched]').length
      return if touchedCount < allCount

    elementAcceptor = $p
    errorClass      = 'field-invalid'
    attributeValue  = viewModel[attribute]()

    if (unlessAttr == true or (unlessAttr and viewModel[unlessAttr]())) or (window[validation](attributeValue))
      elementAcceptor.removeClass(errorClass)
      $(options.resetAlso).removeClass(errorClass) if options.resetAlso
    else
      elementAcceptor.addClass(errorClass)

  update: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    toggleElement = $(element).is(':checkbox, :radio')
    va = viewModel[valueAccessor().accessor]
    handler = if toggleElement then ko.bindingHandlers.checked else ko.bindingHandlers.value
    handler.update(element, va, allBindingsAccessor, viewModel, bindingContext)

    # revalidate
    ko.bindingHandlers.instantValidation.validate(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext)
}
