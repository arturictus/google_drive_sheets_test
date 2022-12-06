# frozen_string_literal: true

require "google/apis/sheets_v4"

module Gat
  class Sheet
    def call()
      sheet
      append
      # Search for files in Drive (first page only)
    end

    def append
      # Add values to rows
      values = [
        %w[Tejaswini Pune Maharashtra India],
        %w[Anjali Mumbai Maharashtra India],
        %w[Avinash Ahmedabad Gujrat India],
        %w[Dhruvin Ahmedabad Gujrat India],
        %w[Sohan Pune Maharashtra India]
      ]

      # Add rows to spreadsheet
      range_name = ["A1:D1"]
      values_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
      service.append_spreadsheet_value(sheet.spreadsheet_id,
                                       range_name,
                                       values_range,
                                       value_input_option: "RAW")
      service.get_spreadsheet(sheet.spreadsheet_id)
    end

    def sheet
      # Always refresh sheet
      @sheet = if File.exist?(id_file)
                 data = File.read(id_file).split
                 service.get_spreadsheet(data[0])
               else
                 request_body = Google::Apis::SheetsV4::Spreadsheet.new
                 response = service.create_spreadsheet(request_body)
                 File.open(id_file, "w") do |f|
                   f.write(response.spreadsheet_id)
                 end
                 # Add columns to spresdsheet
                 cols = [
                   %w[
                     Name City State Country
                   ]
                 ]
                 range_name = ["A1:D1"]
                 col_range = Google::Apis::SheetsV4::ValueRange.new(values: cols)

                 service.update_spreadsheet_value(response.spreadsheet_id,
                                                  range_name,
                                                  col_range,
                                                  value_input_option: "RAW")
                 service.get_spreadsheet(response.spreadsheet_id)
               end
    end

    private

    def service
      return @service if @service

      @service = ::Google::Apis::SheetsV4::SheetsService.new
      @service.authorization = credentials
      @service
    end

    def credentials
      # scope = 'https://www.googleapis.com/auth/androidpublisher'
      scope = ::Google::Apis::SheetsV4::AUTH_SPREADSHEETS

      authorizer = ::Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(auth_file),
        scope: scope
      )

      authorizer.fetch_access_token!
      authorizer
    end

    def auth_file
      File.join(tmp_folder, "credentials.json")
    end

    def id_file
      File.join(tmp_folder, "spreadsheet_id.txt")
    end

    def tmp_folder
      File.expand_path("../../tmp/", __dir__)
    end
  end
end
