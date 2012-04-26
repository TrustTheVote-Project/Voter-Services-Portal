rr = RegistrationRequestForPdf.new(@registration_request)

require 'prawn/measurement_extensions'

prawn_document(page_size: [ 216.mm, 279.mm ], margin: 20) do |pdf|
  # Define fonts
  pdf.font_families.update("Georgia" => {
    normal: "#{Rails.root}/lib/fonts/georgia.ttf"
  })
  pdf.default_leading = 3
  pdf.font_size 9

  render "header", pdf: pdf

  pdf_labeled_block pdf, "Eligibility" do
    pdf_full_width_block pdf do |heights|
      heights << pdf_column_block(pdf, 6, 4, 0) do
        pdf_checkbox pdf, "I am a citizen of the U.S.A, a resident of Virginia, and am at least 18 years of age."
        if rr.voting_rights_revoked?
          pdf_checkbox pdf, "My voting rights were revoked in the past due to a felony."
        end
      end

      if rr.voting_rights_revoked?
        heights << pdf_column_block(pdf, 6, 2, 4) do
          pdf_fields pdf, [
            { columns: 1, value: rr.state_where_convicted, label: 'state where convicted' },
            { columns: 1, value: rr.date_when_restored, label: 'date when restored' } ]
        end
      end
    end
  end

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
        { columns: 2, value: rr.party_preference, label: 'political party preference' }
      ]
    end
  end

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

  pdf_labeled_block pdf, "Oath" do
    pdf_checkbox pdf do
      pdf.font_size 8 do
        pdf.text "<strong>Registration Statement:</strong> I declare under felony penalty that, to the best of my knowledge, the facts contained in this application are true and correct, and that I have not, and will not vote in this election at any other place in Virginia or any other state. Knowingly giving my untrue information in this document is a felony under Virginia law. The maximum penalty is a fine of $2500 and/or confinement for up to ten years.", inline_format: true, leading: 1
      end
    end

    pdf.move_down 10
    pdf_full_width_block pdf do |heights|
      pdf.fill_color "aaaaaa"
      pdf.fill_rectangle [ 0, 0 ], pdf.bounds.width, 70

      pdf.fill_color "000000"
      pdf.indent 16 do
        pdf.move_down 7
        pdf.font_size 10 do
          pdf.text "<strong>Sign and date</strong>", inline_format: true
        end
        pdf.move_down 1
      end

      pdf.bounding_box [ 5, pdf.cursor ], width: pdf.bounds.width - 10 do
        pdf.fill_color "ffffff"
        pdf.fill_rectangle [ 0, 0 ], pdf.bounds.width, 40

        pdf.fill_color "000000"
        pdf.bounding_box [ 10, pdf.cursor - 10 ], width: pdf.bounds.width - 20 do
          pdf_fields pdf, [
            { columns: 7, value: "X", label: "signature" },
            { columns: 1, value: "", label: "date" }
          ]
          pdf.move_down 10
        end
      end
    end
  end
end
