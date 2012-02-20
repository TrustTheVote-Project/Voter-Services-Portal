class Converter

  def self.params_to_date(params, *keys)
    keys.each do |key|
      d = params.delete("#{key}(3i)")
      m = params.delete("#{key}(2i)")
      y = params.delete("#{key}(1i)")
      params[key] = Date.parse("#{y}-#{m}-#{d}") if d && m && y
    end
  end

end
