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

window.filled = (v) -> v && !v.match(/^\s*$/)
window.join   = (a, sep) -> $.map(a, (i) -> if filled(i) then i else null).join(sep)
window.zip5   = (v) -> filled(v) && v.match(/^\d{5}$/)
window.ssn    = (v) -> filled(v) && v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){9}$/)

window.date = (y, m, d) ->
  str = "#{y}-#{m}-#{d}"
  dte = moment(str, "YYYY-M-D")
  if dte.format("YYYY-M-D") == str then dte else false

window.pastDate = (y, m, d) ->
  dte = date(y, m, d)
  if dte && dte.diff(new Date()) < 0 then dte else false

window.phone  = (v) -> v.match(/^([\(\)\-\s]*\d[\(\)\-\s]*){10}$/)
window.email  = (v) -> v.match(/^\S+@\S+\.\S+$/)
window.voterId= (v) -> filled(v) && v.replace(/[^\d]/g, '').match(/^\d{1,9}$/)

window.stepClass = (current, idx, def) ->
  def = def || 'span2'
  match = if $.isArray(idx) then $.inArray(current, idx) > -1 else idx == current
  max   = if $.isArray(idx) then idx[idx.length - 1] else idx
  (if match then 'current ' else if current > max then 'done ' else '') + def

# Value handler that respects the existing value
ko.bindingHandlers.valueWithInit = {
  init: (element, valueAccessor, allBindingsAccessor, context) ->
    property = valueAccessor()
    value = $(element).val()

    ko.bindingHandlers.value.init(element, valueAccessor, allBindingsAccessor, context)
    property(value)
}

ko.bindingHandlers.checkedWithInit = {
  init: (element, valueAccessor, allBindingsAccessor, context) ->
    property = valueAccessor()
    el = $(element)
    checked = el[0].getAttribute('checked') != null
    value   = el.val()

    ko.bindingHandlers.checked.init(element, valueAccessor, allBindingsAccessor, context)
    if checked
      if el.is(":checkbox")
        property(checked)
      else
        property(value)
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
    options = valueAccessor()
    accessor = options.accessor
    attribute = options.attribute || accessor
    validation = options.validation || 'present'

    toggleElement = $(element).is(':checkbox, :radio')
    selectElement = $(element).is('select')
    event = if toggleElement then 'click' else 'blur'

    newValueAccessor = => viewModel[accessor]
    if toggleElement
      ko.bindingHandlers.checkedWithInit.init(element, newValueAccessor, allBindingsAccessor, viewModel)
    else
      ko.bindingHandlers.valueWithInit.init(element, newValueAccessor, allBindingsAccessor, viewModel)

    $(element).bind(event, =>
      if options.complex
        $(element).attr('data-touched', true)
        allCount = $(element).parent().children('[data-bind]').length
        touchedCount = $(element).parent().children('[data-touched]').length
        return if touchedCount < allCount
      elementAcceptor = $(element).parent()
      errorClass = 'field-invalid'
      attributeValue = viewModel[attribute]()

      if window[validation](attributeValue)
        elementAcceptor.removeClass(errorClass)
        $(options.resetAlso).removeClass(errorClass) if options.resetAlso
      else
        elementAcceptor.addClass(errorClass)
    )
}
