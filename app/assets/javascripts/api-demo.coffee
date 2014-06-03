sendRequest = (call, args = {}, cb = null) ->
  q = {
    "eml" : {
      "SchemaVersion" : "7.0",
      "Id" : "310",
      "emlheader" : { "TransactionId" : 310 },
      "VoterRegistration" : {
        "Voter" : {
          "VoterIdentification" : {
            "ElectoralAddress" : {
              "PostalAddress" : {
                "Locality" : $("select#locality").val()
              }
            },

            "VoterPhysicalID" : {
              "VoterPhysicalID-IdType" : "VID",
              "VoterPhysicalID-value" : $("input#voter_id").val()
            },

            "DateOfBirth" : $("input#dob").val(),
            "CheckBox" : {
              "CheckBox-Type" : "IDbyVIDwLocalityDOB",
              "CheckBox-value" : "yes"
            }
          }
        }
      }
    }
  }

  args.q = JSON.stringify(q)

  $("#response").text("Calling...")

  $.ajax({
    type: "GET"
    url: "/api/v1/#{call}"
    data: args
  }).done((json, s, xhr) ->
    $("#response").text(xhr.responseText)
    cb(json) if cb?
  ).fail((xhr) ->
    $("#response").text(xhr.responseText)
  )

$ ->
  $("#btn-polling-location").on 'click', (e) ->
    e.preventDefault()
    sendRequest "PollingLocation", {}, (data) ->
      options = for l in data.polling_locations
        n = l.name
        n = l.address if n.match(/^\s*$/)
        "<option value='#{l.uuid}'>#{n}</option>"
      $("select#pid").html(options.join())

  $("#btn-report-arrive").on 'click', (e) ->
    e.preventDefault()
    sendRequest "ReportArrive", { polling_location_id: $("select#pid").val()}

  $("#btn-report-complete").on 'click', (e) ->
    e.preventDefault()
    sendRequest "ReportComplete", { polling_location_id: $("select#pid").val()}

  $("#btn-wait-time-info").on 'click', (e) ->
    e.preventDefault()
    sendRequest "WaitTimeInfo", { polling_location_id: $("select#pid").val()}
