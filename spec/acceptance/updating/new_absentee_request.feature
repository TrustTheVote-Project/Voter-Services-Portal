@updating @javascript
Feature: making new domestic absentee request

  Scenario: when changing status
    When I look up "residential voter" record
     And initiate change status to domestic absentee
    Then I should not see an absentee checkbox


  Scenario: when updating record
    When I look up "domestic absentee" record
     And I don't change status
    Then I should see an unchecked absentee checkbox
     And when checked, the list of options should be empty
