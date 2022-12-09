module Gat
  class GoogleSpreadSheet
    attr_reader :service, :spreadsheet_id

    def initialize(service, spreadsheet_id)
      @service = service
      @spreadsheet_id = spreadsheet_id
    end

    def write_to(tab_name, data)
      ensure_tab_exists(tab_name, data)

      tab = find_tab(tab_name)
      range = full_range(tab)

      service.clear_values(spreadsheet_id, range)
      service.update_spreadsheet_value(spreadsheet_id, range,
                                       { major_dimension: "ROWS", values: data },
                                       value_input_option: "USER_ENTERED")
    end

    private

    def spreadsheet
      # Always refresh sheet
      service.get_spreadsheet(spreadsheet_id)
    end

    def ensure_tab_exists(tab_name, data)
      return if find_tab(tab_name)

      column_count = data[0].count

      batch_update_spreadsheet_request = build_create_tab_request(tab_name, column_count)

      service.batch_update_spreadsheet(spreadsheet_id,
                                       batch_update_spreadsheet_request)
    end

    def build_create_tab_request(tab_name, column_count) # rubocop:disable Metrics/MethodLength
      Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new.tap do |batch|
        add_sheet_request = Google::Apis::SheetsV4::AddSheetRequest.new.tap do |rq|
          rq.properties = Google::Apis::SheetsV4::SheetProperties.new.tap do |properties|
            properties.title = tab_name
            properties.grid_properties = Google::Apis::SheetsV4::GridProperties.new.tap do |grid|
              grid.column_count = column_count
            end
          end
        end
        batch.requests = [add_sheet: add_sheet_request]
      end
    end

    def find_tab(tab_name)
      spreadsheet.sheets.find { |s| s.properties.title == tab_name }
    end

    def full_range(sheet)
      "'#{sheet.properties.title}'!A1:Z#{sheet.properties.grid_properties.row_count}"
    end
  end
end
