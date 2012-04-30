pdf_labeled_block pdf, "Addresses" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 1, value: rr.registration_address, label: 'registration address' },
      { columns: 1, value: rr.mailing_address, label: 'mailing address' }
    ]

    if rr.overseas?
      pdf.move_down 15
      pdf_fields pdf, [
        { columns: 1, value: rr.residental_address_abroad, label: 'residental address abroad' }
      ]
    end

    if rr.previous_registration?
      pdf.move_down 15
      pdf_full_width_block pdf do |heights|
        heights << pdf_column_block(pdf, 2, 1, 0) do
          pdf_fields pdf, [
            { columns: 1, value: rr.previous_registration_address, label: 'previous registration address' }
          ]
        end

        heights << pdf_column_block(pdf, 2, 1, 1) do
          pdf.indent 10 do
            pdf_checkbox pdf, "Cancel my existing registration."
          end
        end
      end
    end

    if rr.address_confidentiality?
      pdf.move_down 10
      pdf_checkbox pdf, "I quality for address confidentiality (<strong>#{rr.acp_reason}</strong>)"
    end
  end
end
