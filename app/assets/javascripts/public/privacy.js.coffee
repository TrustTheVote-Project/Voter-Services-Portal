class PrivacyPage
  constructor: ->
    @nextBtn = $(".next.bt")
    @nextBtn.on "click", =>
      !@nextBtn.hasClass("disabled")

    @check   = $("input#privacyAgree")
    @check.on "change", @updateBtn

  updateBtn: =>
    if @check.is(":checked")
      @nextBtn.removeClass('disabled')
    else
      @nextBtn.addClass('disabled')

$ ->
  return if $("#privacy").length == 0

  new PrivacyPage()
