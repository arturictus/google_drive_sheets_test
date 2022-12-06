# frozen_string_literal: true

require "google/apis/sheets_v4"
require "google/apis/drive_v3"

module Gat
  class Sheet # rubocop:disable Style/Documentation, Metrics/ClassLength
    def init
      sheet
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
      service.append_spreadsheet_value(sheet.spreadsheet_id,
                                       range_name,
                                       values_range,
                                       value_input_option: "RAW")
      service.get_spreadsheet(sheet.spreadsheet_id)
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

      data_range = ["A1:D6"]
      result = service.batch_get_spreadsheet_values(spreadsheet_id,
                                                    ranges: data_range)

      puts "#{result.value_ranges.length} ranges retrieved."
      puts result.value_ranges[0].values
      result
    end

    def sheet # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # Always refresh sheet
      @sheet = if spreadsheet_id
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
      return @service if @service

      @service = ::Google::Apis::SheetsV4::SheetsService.new
      @service.authorization = credentials
      @service
    end

    def drive
      return @drive if @drive

      # Initialize the drive service
      @drive = Google::Apis::DriveV3::DriveService.new
      @drive.authorization = credentials
      @drive
    end

    def credentials
      # scope = 'https://www.googleapis.com/auth/androidpublisher'
      scope = [Google::Apis::SheetsV4::AUTH_SPREADSHEETS, Google::Apis::DriveV3::AUTH_DRIVE]

      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(auth_file),
        scope: scope
      )

      authorizer.fetch_access_token!
      authorizer
    end

    def spreadsheet_id
      @spreadsheet_id ||= if File.exist?(id_file)
                            data = File.read(id_file).split
                            data[0]
                          end
    end

    def shared_with
      return unless File.exist?(File.join(tmp_folder, "share_with.txt"))

      data = File.read(id_file).split
      data[0]
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
