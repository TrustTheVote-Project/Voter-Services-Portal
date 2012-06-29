top    = pdf.cursor
width  = pdf.bounds.right
height = 65

pdf.save_graphics_state do

  pdf.bounding_box [ 0, top ], width: width, height: height do
    pdf.fill_color "dddddd"
    pdf.fill_rectangle [ 0, pdf.cursor ], width, height

    pdf.font "Georgia", size: 22 do
      pdf.fill_color "000000"
      pdf.text_box 'Virginia Voter Registration', at: [ 10, pdf.cursor - 10 ]
      pdf.fill_color "888888"

      l = @update ? "Update Form #{'(UOCAVA)' if rr.overseas?}" : "Application Form"
      pdf.text_box l, at: [ 10, 30 ]
    end

    if !@update && rr.overseas?
      pdf.text_box 'Overseas / Military Voter', at: [ width - 110, 20 ]
    end
  end

  pdf.move_down 10
end
