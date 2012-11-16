@logging
Feature: Logging

  Scenario: successful lookup
    When the record lookup is successful
    Then an identify record should be created

  Scenario: existing voter begins to change their record
    When voter begins changing their record
    Then an update start record should be created

  Scenario: voter starts filling new form
    When voter begins filling new form
    Then a creation start record should be created

  @javascript
  Scenario: user finishes the updates form
    When voter submits the domestic form update
    Then an update completion record should be created

  @javascript
  Scenario: user finishes new registration
    When voter submits the new form
    Then a new registration completion record should be created

  @javascript
  Scenario: domestic user updates the record and requests absentee
    When voter submits the domestic absentee request
    Then an additional start / complete record should be created

  Scenario: discarded sessions for new registration
    When voter discards new registration session
    Then a discard record for new registration should be created

  Scenario: discarded sessions for registration update
    When voter discards registration update session
    Then a discard record for registration update should be created
