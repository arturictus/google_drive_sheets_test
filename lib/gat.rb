# frozen_string_literal: true

require "google/apis/sheets_v4"
require "google/apis/drive_v3"

module Gat
  class Error < StandardError; end

  class Config # rubocop:disable Style/Documentation
    def sheet_service
      @sheet_service ||= Google::Apis::SheetsV4::SheetsService.new.tap do |s|
        s.authorization = credentials
      end
    end

    def drive
      # Initialize the drive service
      @drive ||= Google::Apis::DriveV3::DriveService.new.tap do |d|
        d.authorization = credentials
      end
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

    def credentials
      scope = [Google::Apis::SheetsV4::AUTH_SPREADSHEETS, Google::Apis::DriveV3::AUTH_DRIVE]

      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
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
      File.expand_path("../tmp/", __dir__)
    end
  end
end
require_relative "gat/version"
require_relative "gat/setup"
require_relative "gat/google_spread_sheet"
require_relative "gat/executor"
