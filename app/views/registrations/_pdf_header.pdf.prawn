top       = pdf.cursor
width     = pdf.bounds.right
height    = 65

title     = "Application Form"
subheader = rr.overseas? ? "Overseas / Military Voter" : nil

if @update
  title, subheader = rr.subheaders
end

pdf.save_graphics_state do

  pdf.bounding_box [ 0, top ], width: width, height: height do
    pdf.fill_color "dddddd"
    pdf.fill_rectangle [ 0, pdf.cursor ], width, height

    pdf.font "Georgia", size: 22 do
      pdf.fill_color "000000"
      pdf.text_box 'Virginia Voter Registration', at: [ 10, pdf.cursor - 10 ]
      pdf.fill_color "888888"
      pdf.text_box title, at: [ 10, 30 ]
    end

    if subheader
      w = subheader =~ /Returning/ ? 150 : 110
      pdf.text_box subheader, at: [ width - w, 20 ]
    end
  end

  pdf.move_down 10
end
