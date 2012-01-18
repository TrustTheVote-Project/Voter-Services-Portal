Feature: Options for unregistered voters

  Scenario:
    Given I am on the front page
     When I submit unknown registration details
     Then I should see "not found"
      And be presented with options

