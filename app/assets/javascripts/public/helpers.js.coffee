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
window.voterId= (v) -> v.replace(/[^\d]/g, '').match(/^\d{16}$/)

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
    checked = el.is(":checked")
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
