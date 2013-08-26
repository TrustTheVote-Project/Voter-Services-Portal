class AbsenteeStatus
  constructor: ->
    @area     = $(".absentee_status .area")

    @loading  = ko.observable(false)
    @loaded   = ko.observable(false)
    @data     = ko.observable(null)

    @templateName = ko.computed =>
      if @data() != null
        if @data().success
          'absentee-status-history'
        else
          'absentee-status-error'
      else if @loading()
        'loading'

  onToggle: =>
    return if @loaded() or @loading()
    @startLoading()

  startLoading: ->
    @loading(true)

    $.getJSON '/lookup/absentee_status_history', @onData

  onData: (data) =>
    @loaded(true)
    @loading(false)
    @data(data)


$ ->
  return if $('body#registration_details').length == 0

  absenteeStatus = new AbsenteeStatus
  $(".absentee_status .toggle").on('click', -> absenteeStatus.onToggle())

  ko.applyBindings
    absenteeStatus: absenteeStatus
