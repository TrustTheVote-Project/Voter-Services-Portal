module FormHelper

  # Checks if we are collecting a certain field for a given form.
  def collecting?(form, field, app_config = AppConfig)
    !!app_config[form.to_s]["collect_#{field}"]
  end

  # Returns the select tags for the date entry and binds them
  def bound_date(f, field, options = {})
    dts = ActionView::Helpers::DateTimeSelector.new(Date.today)

    start_year = options[:start_year] || Date.today.year - 150
    end_year   = options[:end_year] || Date.today.year - 17

    months = options_for_select([ nil ] + 12.times.map { |i| [ dts.send(:month_name, i + 1), i + 1 ] })
    days   = options_for_select([ nil ] + (1 .. 31).to_a)
    years  = options_for_select([ nil ] + (start_year .. end_year).to_a.reverse)
    field  = field.to_s.camelcase(:lower)

    [ select_tag("registration_request[#{field}(2i)]", months, 'data-bind' => "value: #{field}Month"),
      select_tag("registration_request[#{field}(3i)]", days, 'data-bind' => "value: #{field}Day"),
      select_tag("registration_request[#{field}(1i)]", years, 'data-bind' => "value: #{field}Year")
    ].join(' ').html_safe
  end

end
