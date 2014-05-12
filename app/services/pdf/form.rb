class Pdf::Form

  protected

  # Renders PDF and returns it as a string
  def self.render_pdf(pdf_filename, &block)
    pdf_path = "#{Rails.root}/app/assets/pdf-templates/#{pdf_filename}"

    pdf = ActivePdftk::Form.new(pdf_path, path: AppConfig['pdftk_path'])

    block.call(pdf)

    # Flatten to render and remove active form fields
    pdf.save(nil, options: { flatten: true })
  end

  def self.set_digital_field(pdf, key, cells, text)
    return if text.blank?
    cells.times do |i|
      pdf.set("#{key}_#{i + 1}", text[i])
    end
  end

  def self.set_date_field(pdf, key, date)
    set_digital_field(pdf, key, 8, date.strftime('%m%d%Y')) unless date.blank?
  end

  def self.set_short_date_field(pdf, key, date)
    set_digital_field(pdf, key, 6, date.strftime('%m%d%y')) unless date.blank?
  end

end
