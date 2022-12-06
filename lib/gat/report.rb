# frozen_string_literal: true

module Gat
  class Report # rubocop:disable Style/Documentation
    def initialize
      @config = Config.new
    end

    def init
      spreadsheet
      append
    end

    def append # rubocop:disable Metrics/MethodLength
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
      service.append_spreadsheet_value(spreadsheet.spreadsheet_id,
                                       range_name,
                                       values_range,
                                       value_input_option: "RAW")
      service.get_spreadsheet(spreadsheet.spreadsheet_id)
    end

    def share! # rubocop:disable Metrics/MethodLength
      # File id can be obtained when we create / read speard sheer or you can just copy it from your google accout if you wish to share existing speradsheet
      return unless spreadsheet_id
      return unless shared_with

      file_id = spreadsheet_id
      callback = lambda do |res, err|
        raise err.body if err

        puts "Permission ID: #{res.id}"
      end
      # Set permissions for user and specify email address of a user with whom to share
      drive.batch do |_service|
        user_permission = {
          type: "user",
          role: "writer",
          email_address: shared_with
        }

        drive.create_permission(file_id,
                                user_permission,
                                fields: "id",
                                &callback)
      end
    end

    def read
      # we will be using same service object created during speradsheet creation
      result = service.get_spreadsheet(spreadsheet_id)

      puts ">>>>>>>>>> response: #{result.inspect}"

      result.sheets.each do |s|
        puts s.properties.sheet_id
        puts s.properties.index
        puts s.properties.title
        puts s.properties.grid_properties.column_count
      end
      result
    end

    def spreadsheet # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # Always refresh sheet
      @spreadsheet = if spreadsheet_id
                       service.get_spreadsheet(spreadsheet_id)
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
      @config.sheet_service
    end

    def drive
      @config.drive
    end

    def spreadsheet_id
      @config.spreadsheet_id
    end

    def shared_with
      @config.shared_with
    end
  end
end
