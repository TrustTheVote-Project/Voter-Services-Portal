pdf_labeled_block pdf, "Eligibility" do
  pdf_checkbox pdf, "I am a citizen of the U.S.A., a resident of Virginia, and will be at least 18 years of age by the next election day."

  if rr.felony_rights_revoked?
    pdf_full_width_block pdf do |heights|
      heights << pdf_column_block(pdf, 6, 4, 0) do
        pdf_checkbox pdf, "My voting rights were revoked in the past due to a felony."
      end

      heights << pdf_column_block(pdf, 6, 2, 4) do
        pdf_fields pdf, [
          { columns: 1, value: rr.felony_state, label: 'state where convicted' },
          { columns: 1, value: rr.felony_restored_on, label: 'date when restored' } ]
      end
    end
  end

  if rr.mental_rights_revoked?
    pdf_full_width_block pdf do |heights|
      heights << pdf_column_block(pdf, 6, 5, 0) do
        pdf_checkbox pdf, "My voting rights were revoked in the past due to a mental incapacitation."
      end

      heights << pdf_column_block(pdf, 6, 1, 5) do
        pdf_fields pdf, [
          { columns: 1, value: rr.mental_restored_on, label: 'date when restored' } ]
      end
    end
  end
end
