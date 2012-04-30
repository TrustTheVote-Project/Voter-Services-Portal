pdf_labeled_block pdf, "Addresses" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 1, value: rr.registration_address, label: 'registration address' },
      { columns: 1, value: rr.mailing_address, label: 'mailing address' }
    ]

    if rr.previous_registration?
      pdf.move_down 15
      pdf_fields pdf, [
        { columns: 1, value: rr.previous_registration_address, label: 'previous registration address' }
      ]
    end

    if rr.previous_registration? || rr.address_confidentiality?
      pdf.move_down 10
    end

    pdf_full_width_block pdf do |heights|
      if rr.previous_registration?
        heights << pdf_column_block(pdf, 2, 1, 0) do
          pdf_checkbox pdf, "Cancel my existing registration."
        end
      end

      if rr.address_confidentiality?
        heights << pdf_column_block(pdf, 2, 1, 1) do
          pdf_checkbox pdf, "I quality for address confidentiality."
        end
      end
    end
  end
end
