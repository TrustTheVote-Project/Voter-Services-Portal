@javascript
Feature: Validating personal ID for on the client side
  Background:
    Given I am on the front page

  Scenario:
    Then submit button should be disabled

  Scenario:
    When I enter Voter ID
    Then submit button should become enabled

  Scenario:
    When I leave "First name" empty
    Then I should see an error "Cannot be blank" next to "First name"
     And submit button should be disabled

  Scenario:
    When I leave "Last name" empty
    Then I should see an error "Cannot be blank" next to "Last name"
     And submit button should be disabled

  Scenario:
    When I leave "Last 4 digits of SSN" empty
    Then I should see an error "Cannot be blank" next to "Last 4 digits of SSN"
     And submit button should be disabled

  Scenario:
    When I enter short SSN4
    Then I should see an error "Minimum 4 digits please" next to "Last 4 digits of SSN"
     And submit button should be disabled

  Scenario:
    When I leave "Last name" empty
     And enter Voter ID
    Then I should not see "Cannot be blank"
     And submit button should become enabled

