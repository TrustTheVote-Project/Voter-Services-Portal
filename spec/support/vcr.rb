VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.ignore_localhost = true
  c.hook_into :webmock # or :fakeweb
end
