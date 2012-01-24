$ ->
  return unless $('form#new_registration').length > 0

  new BlockToggleField('input#registration_convicted', 'div.convicted')
  new BlockToggleField('input#registration_identify_by_ssn', 'div.ssn')
  new BlockToggleField('input#registration_identify_by_dln', 'div.dln')
