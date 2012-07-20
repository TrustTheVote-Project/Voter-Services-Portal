@updating @javascript
Feature: changing status

  Scenario: from residential voter to overseas absentee
    When I look up "residential voter" record
     And change status to overseas absentee
    Then I should see "Overseas/Military Absentee Voter" on confirm page
     And I should see "Requesting an absentee ballot for elections through"
     And should be able to submit the update


  Scenario: from overseas absentee to residential voter
    When I look up "overseas absentee" record
     And change status to residential voter
    Then I should see "Returning Overseas/Military Absentee Voter" on confirm page
     And I should see "Now residing in Virginia, and submitting registration update in order to vote in the upcoming elections."
     And should be able to submit the update
