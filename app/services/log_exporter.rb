require 'builder'

class LogExporter

  def self.activity(d1, t1, d2, t2)
    records = fetch(LogRecord, d1, t1, d2, t2)
    xml     = Builder::XmlMarkup.new
    puts LogXmlBuilder.build(records, xml)
  end

  def self.errors(d1, t1, d2, t2, separate_lines = false)
    records = fetch(ErrorLogRecord, d1, t1, d2, t2)
    fields  = [ :created_at, :message, :details ]

    if separate_lines
      puts "["
      records.find_each do |r|
        puts "#{r.to_json(only: fields)},"
      end
      puts "]"
    else
      puts records.to_json(only: fields)
    end
  end

  private

  def self.fetch(klass, d1, t1, d2, t2)
    start_date = convert_date(d1, t1)
    end_date   = convert_date(d2, t2)

    records = klass.scoped
    records = records.where([ "created_at >= ?", start_date ]) if start_date
    records = records.where([ "created_at <= ?", end_date ]) if end_date

    records
  end

  def self.convert_date(d, t)
    return nil if d.blank?
    t = '00:01' if t.blank?

    Time.parse([ d, t  ].join(' '))
  end

end
