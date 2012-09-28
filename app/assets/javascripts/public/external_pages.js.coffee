$ ->
  $("div[data-external]").each (i, e) ->
    el  = $(e)
    id = el.attr('data-external')

    # Loader
    loading = $("<div>").addClass('loading').addClass('span10').appendTo(el)
    d = $("<div>").addClass('s').appendTo(loading)
    spinner = new Spinner({
      lines: 9,
      length: 0,
      width: 3,
      radius: 8,
      corners: 0,
      rotate: 0,
      color: '#000',
      speed: 0.8,
      trail: 90,
      shadow: false,
      hwaccel: false,
      className: 'spinner',
      zIndex: 2e9,
      top: 'auto',
      left: 'auto'
    }).spin()
    d.append(spinner.el)

    # Start loading the page
    el.load("/p/" + id)
