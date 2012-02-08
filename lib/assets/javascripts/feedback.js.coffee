Feedback = window.Feedback = {}

# Abstract item that knows how to return feedback based on
# own #isComplete status and subscribe for own change.
class Feedback.AbstractItem
  constructor: (id, @feedbackMessage, @options = {}) ->
    @el = $(id)

  addChangeCallback: (cb) -> @el.change(cb)

  isComplete: =>
    false

  feedback: ->
    # Immediately complete if the condition is met
    skipIf   = @options.skipIf
    complete = (skipIf and skipIf()) or @isComplete()

    @feedbackMessage unless complete


# Simple checker if an element is checked (check box, radio button,
# or a group of either).
class Feedback.Checked extends Feedback.AbstractItem
  isComplete: => @el.is(":checked")


# A field that should be filled.
# The element may have 'data-format' attribute holding a
# regex to verify the format.
class Feedback.Filled extends Feedback.AbstractItem
  addChangeCallback: (cb) ->
    super cb
    @el.keyup(cb)

  isComplete: =>
    fmt = @el.attr('data-format')
    fmt = new RegExp(if fmt then fmt else '^\\w+$')
    @el.val().match(fmt)


# A popover on a given element that displays when there are feedback items.
# Add items to monitor their state.
class Feedback.Popover
  constructor: (id) ->
    @el = $(id).popover(content: @popoverContent, title: @popoverTitle, html: 'html')
    @items = []
    @content = null

  addItem: (i) ->
    @items.push(i)
    i.addChangeCallback(@refresh)
    @refresh()

  popoverTitle: -> "Please review"
  popoverContent: =>
    @content

  refresh: =>
    feedback = []
    for item in @items
      f = item.feedback()
      feedback.push(f) if f

    po = @el.data().popover
    if feedback.length > 0
      po.enabled = true
      @content = "<ul>#{('<li>' + i + '</li>' for i in feedback).join('')}</ul>"
    else
      po.enabled = false
      @content = null

