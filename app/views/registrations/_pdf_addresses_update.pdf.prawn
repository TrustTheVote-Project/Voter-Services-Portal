pdf_labeled_block pdf, "Addresses" do
  pdf_full_width_block pdf do |heights|
    rac = rr.registration_address_changed?
    mac = rr.mailing_address_changed?

    if !rac && !mac
      pdf_fields pdf, [
        { columns: 1, value: rr.registration_address, label: 'registration address' },
        { columns: 1, value: rr.mailing_address, label: 'mailing address' }
      ]
    else
      if rac
        pdf_fields pdf, [
          { columns: 1, value: rr.registration_address, label: 'new registration address' },
          { columns: 1, value: rr.previous_registration_address, label: 'previous registration address' }
        ]
      end

      if rac && mac
        pdf.move_down 15
      end

      if mac
        fields = []
        fields.push({ columns: 1, value: rr.registration_address, label: 'registration address' }) if !rac
        fields.push({ columns: 1, value: rr.mailing_address, label: 'new mailing address' })
        pdf_fields pdf, fields
      end
    end

    er = rr.existing_registration_changed? && rr.existing_registration?
    ac = rr.address_confidentiality?

    if er || ac
      pdf.move_down 15
      pdf_full_width_block pdf do |heights|
        if er
          heights << pdf_column_block(pdf, 2, 1, 0) do
            pdf_fields pdf, [ { columns: 1, value: rr.existing_registration_address, label: 'previous registration address' } ]
          end
        end

        if ac
          heights << pdf_column_block(pdf, 2, 1, 1) do
            pdf_fields pdf, [ { columns: 1, value: rr.acp_reason, label: 'address confidentiality' } ]
          end
        end
      end

      pdf.move_down 15
      pdf_full_width_block pdf do |heights|
        if er
          heights << pdf_column_block(pdf, 2, 1, 0) do
            pdf_checkbox pdf, "Cancel my existing registration"
          end
        end

        if ac
          heights << pdf_column_block(pdf, 2, 1, 1) do
            pdf_checkbox pdf, "I request that my home address not be released"
          end
        end
      end
    end

    if rr.overseas? && rr.mailing_address_availability_changed?
      pdf.move_down 15
      pdf_checkbox pdf, rr.mailing_address_availability
    end
  end
end
