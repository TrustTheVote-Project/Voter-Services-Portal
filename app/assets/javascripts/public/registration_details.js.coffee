class LoadableAccordeon
  constructor: (@dataTemplateName, @jsonURL) ->
    @loading  = ko.observable(false)
    @loaded   = ko.observable(false)
    @data     = ko.observable(null)
    @hidden   = true

    @templateName = ko.computed =>
      if @loading()
        'loading'
      else
        if @data() != null
          if @data().success
            @dataTemplateName
          else
            'error'

  onToggle: =>
    return if @hidden = !@hidden
    return if @loaded() or @loading()
    @startLoading()

  startLoading: ->
    @loading(true)

    $.ajax
      dataType: "json"
      url:      @jsonURL
      data:     {}
      success:  @onData
      error:    @onError

  onError: =>
    @loaded(false)
    @loading(false)
    @data({ success: false, message: 'Communication error. Please try later.' })

  onData: (data) =>
    @loaded(true)
    @loading(false)
    @data(data)

$ ->
  return if $('body#registration_details').length == 0

  absenteeStatus = new LoadableAccordeon('absentee-status', '/lookup/absentee_status_history')
  $(".absentee_status .toggle").on 'click', (e) ->
    e.preventDefault()
    absenteeStatus.onToggle()

  myBallot = new LoadableAccordeon('my-ballot', '/lookup/my_ballot')
  $(".my_ballot .toggle").on 'click', (e) ->
    e.preventDefault()
    myBallot.onToggle()

  ko.applyBindings
    absenteeStatus: absenteeStatus
    myBallot:       myBallot
