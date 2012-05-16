pdf_labeled_block pdf, "Absentee request" do
  pdf_checkbox pdf, "I request absentee status until <strong>#{rr.absentee_status_until}</strong>"

  pdf_full_width_block pdf do |heights|
    heights << pdf_column_block(pdf, 2, 1, 0) do
      pdf_checkbox pdf, rr.absentee_type
    end

    if rr.outside_type_with_details?
      heights << pdf_column_block(pdf, 2, 1, 1) do
        pdf_fields pdf, [
          { columns: 1, value: rr.military_branch, label: 'branch' },
          { columns: 1, value: rr.military_service_id, label: 'service id' },
          { columns: 1, value: rr.military_rank, label: 'rank' }
        ]
      end
    end
  end
end
