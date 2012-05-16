pdf_labeled_block pdf, "Identity" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 4, value: rr.name, label: 'name' },
      { columns: 2, value: rr.email, label: 'email' }
    ]

    pdf.move_down 15
    pdf_fields pdf, [
      { columns: 1, value: rr.ssn, label: 'social security number' },
      { columns: 1, value: rr.dob, label: 'date of birth' },
      { columns: 1, value: rr.phone, label: 'phone' },
      { columns: 1, value: rr.gender, label: 'gender' },
      { columns: 2, value: rr.party_preference, label: 'party preference' }
    ]
  end
end
