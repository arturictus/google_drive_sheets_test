module Gat
  class Lens
    attr_reader :service, :spreadsheet_id

    def initialize(service, spreadsheet_id)
      @service = service
      @spreadsheet_id = spreadsheet_id
    end

    def inspect
      # we will be using same service object created during speradsheet creation
      result = service.get_spreadsheet(spreadsheet_id)

      # puts ">>>>>>>>>> response: #{result.inspect}"

      result.sheets.reduce([]) do |acc, s|
        acc.push({
                   sheet_id: s.properties.sheet_id,
                   index: s.properties.index,
                   title: s.properties.title,
                   column_count: s.properties.grid_properties.column_count
                 })
      end
    end

    def read(sheet = nil)
      data_range = sheet ? ["#{sheet}!A1:D6"] : ["A1:D6"]
      result = service.batch_get_spreadsheet_values(spreadsheet_id,
                                                    ranges: data_range)
      result.value_ranges[0].values
    end
  end
end
