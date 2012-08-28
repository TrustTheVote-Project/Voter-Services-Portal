class Capybara::Node::Simple

  # Finds the selector from the current node and passes it on.
  # Raises an error if unable to find. Useful for stuff like this;
  # xml.within('EML EMLHeader') do |h|
  #   h.should have_selector('Source')
  # end
  def within(sel)
    yield self.find(sel)
  end

end

