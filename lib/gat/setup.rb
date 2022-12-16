# frozen_string_literal: true

module Gat
  class Setup # rubocop:disable Style/Documentation, Metrics/ClassLength
    attr_reader :service, :spreadsheet_id

    def self.call(service, spreadsheet_id)
      new(service, spreadsheet_id).tap(&:setup)
    end

    def initialize(service, spreadsheet_id)
      @service = service
      @spreadsheet_id = spreadsheet_id
    end

    def setup
      spreadsheet
      initial_data_push
    end

    def initial_data_push # rubocop:disable Metrics/MethodLength
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

    def share!(email) # rubocop:disable Metrics/MethodLength
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
          email_address: email
        }

        drive.create_permission(file_id,
                                user_permission,
                                fields: "id",
                                &callback)
      end
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

    def id_file
      Gat::Config.new.id_file
    end

    def full_range(sheet)
      title = sheet.properties.title
      "'#{title}'!A1:Z#{sheet.properties.grid_properties.row_count}"
    end

    def drive
      @config.drive
    end
  end
end
