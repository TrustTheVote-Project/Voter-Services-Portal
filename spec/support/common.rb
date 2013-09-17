def fixture(f)
  File.open(File.join(Rails.root, 'spec/fixtures', f))
end
