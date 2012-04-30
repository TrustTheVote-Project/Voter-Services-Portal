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
