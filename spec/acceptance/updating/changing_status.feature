@updating @javascript
Feature: changing status

  Scenario: to domestic absentee as residential voter
    When I look up "residential voter" record
     And change status to domestic absentee
    Then I should see "Domestic Absentee Voter" on confirm page
     And should be able to submit the update


  Scenario: to overseas as residential voter 
    When I look up "residential voter" record
     And change status to overseas absentee
    Then I should see "Overseas/Military Absentee Voter" on confirm page
     And should be able to submit the update


  Scenario: to residential voter as domestic absentee
    When I look up "domestic absentee" record
     And change status to residential voter
    Then I should see "Virginia Residential Voter" on confirm page
     And should be able to submit the update

