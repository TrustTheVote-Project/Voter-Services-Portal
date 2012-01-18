Feature: Filling a personal identification form
  Background:
    Given I am on the front page

  Scenario:
    When I submit the form
    Then I should be warned of incomplete form

  Scenario:
    When I fill some of required fields
     And submit the form
    Then I should be warned of incomplete form

  Scenario:
    When I fill existing person voter id
     And submit the form
    Then I should see "was found"

  Scenario:
    When I fill unknown person voter id
     And submit the form
    Then I should see "was not found"

  Scenario:
    When I fill required fields of existing person
     And submit the form
    Then I should see "was found"

  Scenario:
    When I fill required fields of unknown person
     And submit the form
    Then I should see "was not found"

