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

  def self.setDigitalField(pdf, key, cells, text)
    return if text.blank?
    cells.times do |i|
      pdf.set("#{key}_#{i + 1}", text[i])
    end
  end

  def self.setDateField(pdf, key, date)
    setDigitalField(pdf, key, 8, date.strftime('%m%d%Y')) unless date.blank?
  end

end
