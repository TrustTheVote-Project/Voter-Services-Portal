rr = RegistrationRequestForPdf.new(@registration_request)

require 'prawn/measurement_extensions'

prawn_document(page_size: [ 216.mm, 279.mm ], margin: 20) do |pdf|
  # Define fonts
  pdf.font_families.update("Georgia" => {
    normal: "#{Rails.root}/lib/fonts/georgia.ttf"
  })
  pdf.default_leading = 3
  pdf.font_size 9

  render "header", pdf: pdf, rr: rr
  render "eligibility", pdf: pdf, rr: rr
  render "identity", pdf: pdf, rr: rr
  render "addresses", pdf: pdf, rr: rr

  if rr.overseas?
    render "absentee_request_overseas", pdf: pdf, rr: rr
  end

  render "oath", pdf: pdf, rr: rr
end
