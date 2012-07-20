@updating @requesting_absentee @javascript
Feature: requesting absentee

  Scenario: as residential voter
    When I look up "residential voter" record
     And keep the status
     And proceed to options page
    Then I should see unchecked absentee request checkbox

  Scenario: as residential voter becoming overseas absentee
    When I look up "residential voter" record
     And choose overseas absentee status option
     And proceed to options page
    Then I should see read-only checked absentee request checkbox

  Scenario: as overseas absentee
    When I look up "overseas absentee" record
     And keep the status
     And proceed to options page
    Then I should see read-only checked absentee request checkbox

  Scenario: as returning overseas absentee
    When I look up "overseas absentee" record
     And choose residential voter status option
     And proceed to options page
    Then I should see unchecked absentee request checkbox
