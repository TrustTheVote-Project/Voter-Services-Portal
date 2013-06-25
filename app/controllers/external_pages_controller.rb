class ExternalPagesController < ApplicationController

  def show
    require 'open-uri'

    config = AppConfig['static_pages']
    base = config['url_base']
    page = params[:id].to_s.gsub(/[^a-z_\-]/i, '')
    path = config[page]

    res  = open("#{base}/#{path}").read.gsub(/(^.*<body[^>]*>|<\/body>.*$)/mi, '')
  rescue OpenURI::HTTPError => e
    if e.message =~ /404/
      res = "Page not found (#{path})."
    else
      res = "We are sorry. This page is currently unavailable."
    end
  ensure
    render text: res
  end

end
