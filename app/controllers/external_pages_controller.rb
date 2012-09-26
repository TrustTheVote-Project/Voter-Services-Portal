class ExternalPagesController < ApplicationController

  def show
    require 'open-uri'

    base = AppConfig['static_page_url_base']
    page = params[:id].to_s.gsub(/[^a-z_\-]/i, '')

    res  = open("#{base}/#{page}.htm").read.gsub(/(^.*<body[^>]*>|<\/body>.*$)/mi, '')
  rescue OpenURI::HTTPError => e
    if e.message =~ /404/
      res = "Page not found (#{page}.htm)."
    else
      res = "We are sorry. This page is currently unavailable."
    end
  ensure
    render text: res
  end

end
