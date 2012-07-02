pdf_labeled_block pdf, "Identity" do
  pdf_full_width_block pdf do |heights|

    # Name and email
    fields = [
      { columns: 4, value: rr.name, label: rr.name_changed? ? "new name" : "name" }
    ]

    if rr.email_changed?
      fields << { columns: 2, value: rr.email, label: 'new email' }
    end

    pdf_fields pdf, fields

    if rr.name_changed? 
      pdf.move_down 15
      pdf_fields pdf, [
        { columns: 4, value: rr.previous_name, label: 'previous name' }
      ]
    end
      

    pdf.move_down 15
    fields = [
      { columns: 1, value: rr.ssn, label: 'social security number' },
      { columns: 1, value: rr.dob, label: 'date of birth' }
    ]

    if rr.phone_changed?
      fields << { columns: 1, value: rr.phone, label: 'new phone' }
    else
      fields << { columns: 1, value: '', label: '' }
    end

    fields << { columns: 1, value: rr.gender, label: 'gender' }

    if rr.party_changed?
      fields << { columns: 2, value: rr.party_preference, label: 'new party preference' }
    else
      fields << { columns: 2, value: '', label: '' }
    end

    pdf_fields pdf, fields

    if rr.being_official?
      pdf.move_down 15
      pdf_checkbox pdf, "I'm interested in being an Election Official on Election Day. Please send me information."
    end
  end
end
