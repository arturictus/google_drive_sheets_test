module Gat
  class Lens
    attr_reader :service, :spreadsheet_id

    def initialize
      config = Config.new
      @service = config.service
      @spreadsheet_id = config.spreadsheet_id
    end

    def inspect # rubocop:disable Metrics/AbcSize
      # we will be using same service object created during speradsheet creation
      result = service.get_spreadsheet(spreadsheet_id)

      # puts ">>>>>>>>>> response: #{result.inspect}"

      result.sheets.each do |s|
        puts s.properties.sheet_id
        puts s.properties.index
        puts s.properties.title
        puts s.properties.grid_properties.column_count
      end
      result
    end

    def read(sheet = nil)
      data_range = sheet ? ["#{sheet}!A1:D6"] : ["A1:D6"]
      result = service.batch_get_spreadsheet_values(spreadsheet_id,
                                                    ranges: data_range)
      result.value_ranges[0].values
    end
  end
end
