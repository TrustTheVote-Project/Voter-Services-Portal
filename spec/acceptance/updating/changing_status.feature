@updating @javascript
Feature: changing status

  Scenario: from residential voter to domestic absentee
    When I look up "residential voter" record
     And change status to domestic absentee
    Then I should see "Virginia Residential Voter" on confirm page
     And I should see "I am not able to go to the polls on election day and would like to request an Absentee Ballot"
     And should be able to submit the update


  Scenario: from residential voter to overseas absentee
    When I look up "residential voter" record
     And change status to overseas absentee
    Then I should see "Virginia Residential Voter" on confirm page
     And I should see "I am living overseas and won't be in the U.S. on election day and need an Ansentee Ballot."
     And should be able to submit the update


  Scenario: from domestic absentee to residential voter
   Given domestic absentees allowed change status to residential voters
    When I look up "domestic absentee" record
     And change status to residential voter
    Then I should see "Domestic Absentee Voter" on confirm page
     And I should see "I will attend polls personally... TBD"
     And should be able to submit the update


  Scenario: from domestic absentee when residential voting not allowed
   Given domestic absentees not allowed change status to residential voters
    When I look up "domestic absentee" record
    Then I should not see "Virginia Residential Voter" option


  Scenario: to residential voter as overseas absentee
    When I look up "overseas absentee" record
     And change status to residential voter
    Then I should see "Overseas/Military Absentee Voter" on confirm page
     And should be able to submit the update
