# frozen_string_literal: true

module Gat
  class Actions
    attr_reader :spreadsheet_id, :service

    def initialize(spreadsheet_id, service)
      @spreadsheet_id = spreadsheet_id
      @service = service
    end

    def delete_tab(tab)
      # Create a batch update request body
      request_body = {
        requests: [
          {
            delete_sheet: {
              sheet_id: spreadsheet_id,
              shift_dimension: {
                sheet_index: tab.properties.sheet_id,
                dimension: "ROWS",
                number: 0,
                shift: "UP"
              }
            }
          }
        ]
      }

      # Execute the batch update request
      service.batch_update_spreadsheet(spreadsheet_id, request_body)
    end

    def increase_rows(tab, data)
      current_row_length = tab.properties.grid_properties.row_count
      return if current_row_length >= data.count

      request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(
        request: [
          insert_dimension: Google::Apis::SheetsV4::InsertDimensionRequest.new(
            range: Google::Apis::SheetsV4::DimensionRange.new(sheet_id: tab.properties.sheet_id,
                                                              dimension: "ROWS",
                                                              start_index: current_row_length,
                                                              end_index: data.count),
            inherit_from_before: true
          )
        ]
      )
      # Insert the new rows at the end of the spreadsheet
      service.batch_update_spreadsheet(spreadsheet_id, request)
    end

    def create_tab(tab_name, column_count:, row_count:) # rubocop:disable Metrics/AbcSize
      request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new.tap do |batch|
        add_sheet_request = Google::Apis::SheetsV4::AddSheetRequest.new.tap do |rq|
          rq.properties = Google::Apis::SheetsV4::SheetProperties.new.tap do |properties|
            properties.title = tab_name
            properties.grid_properties = Google::Apis::SheetsV4::GridProperties.new.tap do |grid|
              grid.column_count = column_count
              grid.row_count = row_count
            end
          end
        end
        batch.requests = [add_sheet: add_sheet_request]
      end

      service.batch_update_spreadsheet(spreadsheet_id,
                                       request)
    end
  end
end
