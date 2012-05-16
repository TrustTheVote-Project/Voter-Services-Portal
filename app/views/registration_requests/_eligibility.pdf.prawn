pdf_labeled_block pdf, "Eligibility" do
  pdf_checkbox pdf, "I am a citizen of the U.S.A., a resident of Virginia, and will be at least 18 years of age by the next election day."

  if rr.rights_revoked?
    pdf_full_width_block pdf do |heights|
      heights << pdf_column_block(pdf, 6, 4, 0) do
        pdf_checkbox pdf, "My voting rights were revoked in the past due to a #{rr.rights_revokation_reason}."
      end

      heights << pdf_column_block(pdf, 6, 2, 4) do
        fields = [
          { columns: 1, value: rr.rights_restored_on, label: 'date when restored' }
        ]
        if rr.rights_revoked_felony?
          fields.unshift({ columns: 1, value: rr.felony_state, label: 'state where convicted' })
        end
        pdf_fields pdf, fields
      end
    end
  end
end
