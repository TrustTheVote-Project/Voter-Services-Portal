class Array

  def rjoin(sep = '')
    self.reject(&:blank?).join(sep)
  end

end
