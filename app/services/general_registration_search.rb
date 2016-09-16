class GeneralRegistrationSearch

  def self.perform(search_query, config)
    params = {
        "voter_records_request" => {
            "generated_date" => Time.now.to_s,
            "type" => "lookup",
            "request_source" => {
                "name" => "Elections Ontario",
                "type" => "voter-via-internet"
            },
            "voter_registration" => {
                "date_of_birth" => search_query.date_of_birth.strftime('%Y-%m-%d'),
                "registration_address" => {
                    "numbered_thoroughfare_address" => {
                        "complete_address_number" => {
                            "address_number" => search_query.street_number
                        },
                        "complete_street_name" => {
                            "street_name" => search_query.street_name
                        }
                    }
                },
                "name" => {
                    "first_name" => search_query.first_name,
                    "last_name" => search_query.last_name
                }
            }
        }
    }
    uri = URI(config['url'])
    Rails.logger.info(uri.to_s)
    result = nil

    begin
      raise 'generic lookup service is not configured' if config['url'].blank?
      Rails.logger.debug params.to_json
      LookupApi.post_request(uri, params) do |response|
        if response.code == '200'
          result = JSON.parse(response.body)
          Rails.logger.debug(result)
        else
          Rails.logger.error "LookupApi error: #{response.code}, #{response.body}."
          # required to show not found screen
          raise LookupApi::RecordNotFound
        end
      end
    rescue Timeout::Error
      Rails.logger.error "LOOKUP: timeout URL: #{uri}" if AppConfig['api_debug_logging']
      ErrorLogRecord.log("LOOKUP: timeout", uri: uri)
      LogRecord.lookup_timeout(uri)

      raise LookupApi::RecordNotFound
    end

    VriAdapter.new(result).to_registration
  end
end
