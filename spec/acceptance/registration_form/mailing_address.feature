@javascript @registration_form
Feature: Mailing address

  Scenario: after choosing rural registration address
    When I start new registration
     And choose rural registration address
    Then mailing address same as registration selector should disappear
     And mailing address form should be visible

  Scenario: after deselecting rural registration address
    When I start new registration
     And choose rural registration address
     And unselect rural registration address
    Then mailing address selector should appear
     And mailing address should be marked as not being the same as registration address
     And mailing address form should be visible
