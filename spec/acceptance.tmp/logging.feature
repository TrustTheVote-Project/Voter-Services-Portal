@logging
Feature: Logging

  Scenario: successful lookup
    When record lookup is successful
    Then identify record should be created

  # --- NEW REGISTRATION ---

  Scenario: start domestic registration
    When started domestic registration
    Then start "VoterRegistration" should be logged

  Scenario: start overseas registration
    When started overseas registration
    Then start "VoterRegistrationAbsenteeRequest" should be logged

  @javascript
  Scenario: complete domestic registration
    When completed domestic registration
    Then complete "VoterRegistration" should be logged
     And start "AbsenteeRequest" should not be logged
     And complete "AbsenteeRequest" should not be logged

  @javascript
  Scenario: complete overseas registration
    When completed overseas registration
    Then complete "VoterRegistrationAbsenteeRequest" should be logged
     And start "AbsenteeRequest" should not be logged
     And complete "AbsenteeRequest" should not be logged

  @javascript
  Scenario: complete domestic registration with absentee request
    When completed domestic registration with absentee request
    Then complete "VoterRegistration" should be logged
     And start "AbsenteeRequest" should be logged
     And complete "AbsenteeRequest" should be logged

  # --- DOMESTIC UPDATES ---

  Scenario: start domestic update
    When started domestic update
    Then start "VoterRecordUpdate" should be logged

  @javascript
  Scenario: complete domestic update with only form changes
    When completed domestic update with only form changes
    Then complete "VoterRecordUpdate" should be logged

  @javascript
  Scenario: complete domestic update with absentee request and no form changes
    When completed domestic update with absentee request and no form changes

    # If this one fails, check that you are ignoring all necessary fields when
    # checking if this is an absentee request only (Registration#IGNORE_CHANGES_IN_KEYS)
    # or check that you have this fields in RegistrationSearch
    Then complete "AbsenteeRequest" should be logged
     And start "AbsenteeRequest" should be logged
     And start "VoterRecordUpdate" should not be logged

  @javascript
  Scenario: complete domestic update with absentee request and form changes
    When completed domestic update with absentee request and form changes
    Then complete "VoterRecordUpdateAbsenteeRequest" should be logged
     And start "VoterRecordUpdateAbsenteeRequest" should be logged
     And start "VoterRecordUpdate" should not be logged

  # --- OVERSEAS UPDATES ---

  Scenario: start overseas update
    When started overseas update
    Then start "VoterRecordUpdate" should be logged

  @javascript
  Scenario: complete overseas update
    When completed overseas update
    Then complete "VoterRecordUpdate" should be logged
     And complete "AbsenteeRequest" should not be logged

