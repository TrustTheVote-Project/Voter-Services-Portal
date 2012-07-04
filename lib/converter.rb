class Converter

  def self.params_to_date(params, *keys)
    keys.each do |key|
      d = params.delete("#{key}(3i)")
      m = params.delete("#{key}(2i)")
      y = params.delete("#{key}(1i)")
      params[key] = Date.parse("#{y}-#{m}-#{d}") unless d.blank? || m.blank? || y.blank?
    end
  end

  def self.params_to_time(params, *keys)
    keys.each do |key|
      params.delete("#{key}(3i)")
      params.delete("#{key}(2i)")
      params.delete("#{key}(1i)")
      if params.has_key?("#{key}(4i)") && params.has_key?("#{key}(5i)")
        h = params.delete("#{key}(4i)")
        m = params.delete("#{key}(5i)")
        unless h.blank? || m.blank?
          params[key] = Time.parse("#{h}:#{m}")
        else
          params[key] = nil
        end
      end
    end
  end

end
