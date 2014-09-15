class Pdf::Form

  protected

  # Renders PDF and returns it as a string
  def self.render_pdf(pdf_key, &block)
    pdf_filename = AppConfig['customization'].try(:[], pdf_key)
    if pdf_filename.blank?
      raise "Path for PDF form by key '#{pdf_key}' is unspecified"
    end

    # If #pdf_filename is an absolute path, it will be used as-is.
    # If it is a relative path, it will be merged with the pdf-templates folder path.
    pdf_path = File.absolute_path(pdf_filename, "#{Rails.root}/app/assets/pdf-templates")
    if !File.exists?(pdf_path)
      raise "PDF file is missing: #{pdf_path}"
    end

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
