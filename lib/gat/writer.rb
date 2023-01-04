module Gat
  class Writer
    CHUNK_SIZE = 500
    attr_reader :service, :spreadsheet_id, :batches

    def initialize(service, spreadsheet_id)
      @service = service
      @spreadsheet_id = spreadsheet_id
      @batches = []
    end

    def write_to(tab_name, data)
      ensure_tab_exists(tab_name, data)
      tab = find_tab(tab_name)

      service.clear_values(spreadsheet_id, full_range(tab))
      write_in_chunks_to(tab, data)
    end

    private

    def write_in_chunks_to(tab, data)
      data.each_slice(CHUNK_SIZE).reduce(1) do |init_col, chunk|
        chunk_range = "'#{tab.properties.title}'!A#{init_col}:Z#{init_col + chunk.size - 1}"
        batches << {chunk:, range: chunk_range}
        service.update_spreadsheet_value(spreadsheet_id, chunk_range,
          {major_dimension: "ROWS", values: chunk},
          value_input_option: "USER_ENTERED")
        init_col + chunk.size
      end
    end

    def spreadsheet
      # Always refresh sheet
      service.get_spreadsheet(spreadsheet_id)
    end

    def ensure_tab_exists(tab_name, data)
      if tab = find_tab(tab_name)
        current_row_length = tab.properties.grid_properties.row_count
        return if current_row_length >= data.count
        dimension_request = Google::Apis::SheetsV4::InsertDimensionRequest.new(
          range: Google::Apis::SheetsV4::DimensionRange.new(sheet_id: tab.properties.sheet_id,
          dimension: 'ROWS',
          start_index: current_row_length,
          end_index: data.count),
          inherit_from_before: true
        )


        batch_update_spreadsheet_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new
        batch_update_spreadsheet_request.requests = [insert_dimension: dimension_request]


        # Insert the new rows at the end of the spreadsheet
        service.batch_update_spreadsheet(spreadsheet_id, batch_update_spreadsheet_request)
      else
        column_count = data[0].count

        batch_update_spreadsheet_request = build_create_tab_request(tab_name, column_count)

        service.batch_update_spreadsheet(spreadsheet_id,
                                        batch_update_spreadsheet_request)
      end
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

    def _chunked_range(tab, init_col, last_col)
      "'#{tab.properties.title}'!A#{init_col}:Z#{last_col}"
    end

    def full_range(tab, rows = nil)
      rows ||= tab.properties.grid_properties.row_count
      "'#{tab.properties.title}'!A1:Z#{rows}"
    end
  end
end
