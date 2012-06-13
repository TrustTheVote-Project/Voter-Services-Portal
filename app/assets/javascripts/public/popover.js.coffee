class window.Popover
  constructor: (id, errors) ->
    @errors = errors
    @el = $(id).popover(content: @popoverContent, title: 'Please review', html: 'html')
    @po = @el.data().popover

    errors.subscribe @update
    @update()

  update: =>
    @po.enabled = @errors().length > 0

  popoverContent: =>
    items = @errors()
    if items.length > 0
      "<ul>#{('<li>' + i + '</li>' for i in items).join('')}</ul>"
    else
      null

