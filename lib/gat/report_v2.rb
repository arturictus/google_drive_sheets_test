# frozen_string_literal: true

module Gat
  class ReportV2
    attr_reader :config

    REPORT_SHEET_NAME = "System export"

    def initialize
      @config = Config.new
    end

    def upload_to_google_sheets(report)
      return unless spreadsheet_id

      write_to("status", status_msg(:in_process))

      write_to(REPORT_SHEET_NAME, report)

      write_to("status", status_msg(:done))
    end

    private

    def write_to(sheet_name, data) # rubocop:disable Metrics/MethodLength
      ensure_sheet_exists(sheet_name, data)
      sheet = find_sheet(sheet_name)

      raise "Sheet does not exist" unless sheet

      range = full_range(sheet)

      value_range_object = {
        major_dimension: "ROWS",
        values: data
      }

      service.clear_values(spreadsheet_id, range)
      service.update_spreadsheet_value(spreadsheet_id, range,
                                       value_range_object,
                                       value_input_option: "USER_ENTERED")
    end

    def spreadsheet
      # Always refresh sheet
      service.get_spreadsheet(spreadsheet_id)
    end

    def status_msg(status)
      [
        ["THIS SPREADSHEET IS AUTOMATICALLY GENERATED BY THE SELMA SYSTEM. DO NOT MANUALLY EDIT THIS SPREADSHEET."]
      ].tap do |data|
        case status
        when :in_process
          data.push(["Uploading data in progress since… #{Time.now}"])
        when :done
          data.push(["Data uploaded successfully on #{Time.now}"])
        else
          raise "Unkown Status"
        end
      end
    end

    def ensure_sheet_exists(sheet_name, data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return if find_sheet(sheet_name)

      column_count = data[0].count

      add_sheet_request = Google::Apis::SheetsV4::AddSheetRequest.new
      add_sheet_request.properties = Google::Apis::SheetsV4::SheetProperties.new
      add_sheet_request.properties.title = sheet_name

      grid_properties = Google::Apis::SheetsV4::GridProperties.new
      grid_properties.column_count = column_count
      add_sheet_request.properties.grid_properties = grid_properties

      batch_update_spreadsheet_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new
      batch_update_spreadsheet_request.requests = Google::Apis::SheetsV4::Request.new

      batch_update_spreadsheet_request_object = [add_sheet: add_sheet_request]
      batch_update_spreadsheet_request.requests = batch_update_spreadsheet_request_object

      service.batch_update_spreadsheet(spreadsheet_id,
                                       batch_update_spreadsheet_request)
    end

    def find_sheet(sheet_name)
      spreadsheet.sheets.find { |s| s.properties.title == sheet_name }
    end

    def full_range(sheet)
      "'#{sheet.properties.title}'!A1:Z#{sheet.properties.grid_properties.row_count}"
    end

    def spreadsheet_id
      config.spreadsheet_id
    end

    def service
      config.sheet_service
    end
  end
end