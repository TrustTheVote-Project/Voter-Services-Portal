class Array

  def rjoin(sep = '')
    self.reject(&:blank?).join(sep)
  end

  def humanized_list_join
    a = self.clone
    l = a.pop
    [ a.join(', '), l ].rjoin(' and ')
  end

end
