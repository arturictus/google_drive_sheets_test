module Gat
  class Writer
    CHUNK_SIZE = 500
    attr_reader :service, :spreadsheet_id, :actions, :batches

    def initialize(service, spreadsheet_id)
      @service = service
      @spreadsheet_id = spreadsheet_id
      @actions = Actions.new(spreadsheet_id, service)
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
      if (tab = find_tab(tab_name))
        actions.increase_rows(tab, data)
      else
        column_count = data[0].count

        actions.create_tab(tab_name, column_count: column_count, row_count: data.count)
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
