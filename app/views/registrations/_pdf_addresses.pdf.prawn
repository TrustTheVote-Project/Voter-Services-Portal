pdf_labeled_block pdf, "Addresses" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 1, value: rr.registration_address, label: 'registration address' },
      { columns: 1, value: rr.mailing_address, label: 'mailing address' }
    ]


    pdf.move_down 15
    pdf_full_width_block pdf do |heights|
      if rr.previous_registration?
        heights << pdf_column_block(pdf, 2, 1, 0) do
          pdf_fields pdf, [ { columns: 1, value: rr.previous_registration_address, label: 'previous registration address' } ]
        end
      end

      if rr.address_confidentiality?
        heights << pdf_column_block(pdf, 2, 1, 1) do
          pdf_fields pdf, [ { columns: 1, value: rr.acp_reason, label: 'address confidentiality' } ]
        end
      end
    end

    pdf.move_down 15
    pdf_full_width_block pdf do |heights|
      if rr.previous_registration?
        heights << pdf_column_block(pdf, 2, 1, 0) do
          pdf_checkbox pdf, "Cancel my existing registration"
        end
      end

      if rr.address_confidentiality?
        heights << pdf_column_block(pdf, 2, 1, 1) do
          pdf_checkbox pdf, "I request that my home address not be released"
        end
      end
    end
  end
end
