class LookupService

  # stub registration lookup
  def self.registration(record)
    if record[:dmv_id].size == 12
      { registered: true }
    elsif record[:dmv_id].size == 9
      { registered: false, dmv_match: true,
        address: {
          street_number:  "123",
          street_name:    "WannaVote",
          street_type:    "DR",
          county_or_city: "ALEXANDRIA CITY",
          zip5:           "12345"
        }
      }
    else
      { registered: false, dmv_match: false }
    end
  end

  # runs a lookup for the record
  def self.registration_for_record(r)
    rights_revoked = r.rights_revoked == '1'
    revoked_felony = rights_revoked && r.rights_revoked_reason == 'felony'
    revoked_competence = rights_revoked && r.rights_revoked_reason == 'mental'
    return LookupService.registration({
      eligible_citizen:             r.citizen,
      eligible_18_next_election:    r.old_enough,
      eligible_revoked_felony:      revoked_felony,
      eligible_revoked_competence:  revoked_competence,
      dob:                          r.dob ? r.dob.strftime("%m/%d/%Y") : '',
      ssn:                          r.ssn,
      dmv_id:                       r.dmv_id || ''
    })
  end
end
