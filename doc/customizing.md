Customizing
===========

CSS
---

Portal is capable of loading custom stylesheets for desktop and mobile
versions of the application after the general defaults. You can specify
either relative or absolute URLs for stylesheets to load in
`config.yml`.


    customization:
      application_css:  custom_application.css
      mobile_css:       http://myother.wesite.com/portal_mobile.css

In the example above two stylesheets are added -- one for the
desktop (relative -- `app/assets/stylesheets/custom_application.css`)
and one for the mobile version (absolute).


Images
------

Images are customized through stylesheets. If you need to replace a
certain image, place it somewhere accessible on the web (Amazon S3, for
example), and create a custom stylesheet as described above to wire it.


PDF
---

Default PDF forms reside in `app/assets/pdf-templates`. The names of
files from this folder are in `config.yml`. You can specify alternative
PDF files to use by specifying paths either absolute, or relative to the
default files folder mentioned above.

