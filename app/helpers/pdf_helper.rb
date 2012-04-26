module PdfHelper

  BORDER_COLOR = "CCCCCC"
  LABEL_COLOR  = "888888"
  LABEL_FONT   = "Georgia"
  COLUMN_PADDING = 10

  class PadCallback

    LEFT_PADDING = 2

    def initialize(options)
      @color = "ffffff"
      @document = options[:document]
    end

    def render_behind(fragment)
      original_color = @document.fill_color
      @document.fill_color = @color
      @document.fill_rectangle [ fragment.left - LEFT_PADDING, fragment.top ], fragment.width + 2 * LEFT_PADDING, fragment.height
      @document.fill_color = original_color
    end
  end

  def pdf_full_width_block(pdf, &block)
    heights = []
    pdf.bounding_box [ 0, pdf.cursor ], width: pdf.bounds.right do
      block.call heights

      unless heights.blank?
        leading = heights.last
        pdf.move_down heights.map { |h| h - leading }.max
      end
    end
  end

  def pdf_column_block(pdf, columns, span, first_column, &block)
    total_width  = pdf.bounds.width
    column_width = total_width / columns
    width = column_width * span
    left  = first_column * column_width

    height = 0
    pdf.bounding_box [ left, pdf.bounds.top ], width: width do
      block.call
      height = pdf.bounds.height
    end

    return height
  end

  def pdf_checkbox(pdf, label = nil, &block)
    pdf.image "#{Rails.root}/lib/prawn/checkbox.png", at: [ 0, 0 ], scale: 0.75
    pdf.indent 16 do
      if block
        block.call
      else
        pdf.text label
      end
    end
  end

  def pdf_fields(pdf, data)
    table_values = data.map { |f| f[:value] }
    table_labels = data.map { |f| f[:label] }

    total_columns = data.inject(0) { |m, f| m + f[:columns] }
    per_column    = pdf.bounds.width / total_columns

    pdf.table [ table_values, table_labels ], column_widths: data.map { |f| f[:columns] * per_column } do
      cells.borders = []
      cells.border_color = "444444"

      row(0).borders = [ :bottom ]
      row(0).padding = [ 0, COLUMN_PADDING, 3, 0]
      row(1).size = 7
      row(1).padding = [ 1, COLUMN_PADDING, 3, 0 ]
      row(1).text_color = "444444"
    end
  end

  def pdf_labeled_block(pdf, label, &block)
    pdf.bounding_box [ 0, pdf.cursor - 10 ], width: pdf.bounds.right do
      # Internal padded content
      pdf.bounding_box [ 10, pdf.cursor - 15 ], width: pdf.bounds.right - 20 do
        block.call
        pdf.move_down 10
      end

      # Stroke the border
      sc = pdf.stroke_color
      pdf.stroke_color BORDER_COLOR
      pdf.stroke_bounds
      pdf.stroke_color sc

      # Draw the label
      current_cursor = pdf.cursor
      pdf.bounding_box [ 10, pdf.bounds.top + 6 ], width: pdf.bounds.right - 20 do
        pad = PadCallback.new(document: pdf)
        pdf.font LABEL_FONT, size: 12 do
          pdf.formatted_text [ { text: label, callback: pad, color: LABEL_COLOR } ]
        end
      end
      pdf.move_cursor_to current_cursor

      # Bottom margin
      pdf.move_down 10

    end
  end

end
