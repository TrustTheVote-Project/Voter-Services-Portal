@updating @javascript
Feature: Making no updates during the update and review workflow

  Scenario: as residential voter
    When I look up "residential voter" record
    Then I should see view and update page
     And I should see "Virginia Residential Voter" status selected

    When I proceed without making changes
    Then I should see the download page
     And the next button should be disabled

  Scenario: as overseas absentee voter
    When I look up "overseas" record
    Then I should see view and update page
     And I should see "Overseas/Military Absentee Voter" status selected

    When I proceed without making changes
    Then I should see the download page
     And the next button should be disabled
