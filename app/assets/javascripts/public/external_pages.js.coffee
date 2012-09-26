$ ->
  $("div[data-external]").each (i, e) ->
    el  = $(e)
    id = el.attr('data-external')

    # Loader
    loading = $("<div>").addClass('loading').addClass('span10').appendTo(el)
    d = $("<div>").addClass('s').appendTo(loading)
    $("<div>").addClass('l').text('Loading. Please wait...').appendTo(loading)
    spinner = new Spinner().spin()
    d.append(spinner.el)

    # Start loading the page
    el.load("/p/" + id)
