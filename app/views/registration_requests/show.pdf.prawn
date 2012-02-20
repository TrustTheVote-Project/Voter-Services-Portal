rr = @registration_request
prawn_document() do |pdf|
  pdf.text "Hello, #{[ rr.title, rr.first_name, rr.middle_name, rr.last_name, rr.suffix].join(' ').squeeze}"
end
