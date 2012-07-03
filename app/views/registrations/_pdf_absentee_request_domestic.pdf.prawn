pdf_labeled_block pdf, "Absentee" do
  pdf_checkbox pdf, "I will not be able to vote in person, and would like to vote absentee"
  pdf_checkbox pdf, rr.absence_reason

  af = rr.absence_fields
  aa = rr.absence_address
  tr = rr.absence_time_range

  unless af.blank?
    pdf_fields pdf, af
  end

  fields = []
  fields << { columns: 1, value: aa, label: 'address' } unless aa.blank?
  fields << { columns: 1, value: tr, label: 'time range' } unless tr.blank?

  unless fields.empty?
    if !af.blank?
      pdf.move_down 15
    end
    pdf_fields pdf, fields
  end

end
