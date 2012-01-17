@javascript
Feature: Validating personal ID for on the client side
  Background:
    Given I am on the front page

  Scenario:
    Then submit button should be disabled

  Scenario:
    When I enter Voter ID
    Then submit button should become enabled
