# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat::Executor do

  context "Small file" do
    before do
      @config = Gat::Config.new
      VCR.use_cassette("executor_example_3_setup") do
        Gat::Setup.call(@config.sheet_service, "1rVp5IVZhax3jPyP_fdpdpM_z-MdQU0QPwWhnv6bIBJM")
      end
      @service = @config.sheet_service
      @spreadsheet_id = @config.spreadsheet_id
    end
    it "uploads the report to Google Sheets" do
      executor = Gat::Executor.new(@service, @spreadsheet_id)
      VCR.use_cassette("executor_example_3") do
        executor.upload_to_google_sheets([%w[hello this is a test], %w[hello this is a test]])
      end

      puts executor.spreadsheet.batches

      lens = Gat::Lens.new(@service, @spreadsheet_id)
      VCR.use_cassette("executor_example_3_read") do

        inspect = lens.inspect()
        expect(inspect[0][:title]).to eq("Sheet1")
        expect(inspect[1][:title]).to eq("status")
        expect(inspect[2][:title]).to eq("System export")
        report = lens.read(Gat::Executor::REPORT_SHEET_NAME)
        expect(report).to eq([%w[hello this is a], %w[hello this is a]])
        status = lens.read("Status")
        expect(status[0][0]).to eq("THIS SPREADSHEET IS AUTOMATICALLY GENERATED BY THE SELMA SYSTEM. DO NOT MANUALLY EDIT THIS SPREADSHEET.")
        expect(status[1][0]).to match("Data uploaded successfully on")
      end
    end

    it "Try rerun executor" do
      VCR.use_cassette("executor_example_3_rewrite") do
        executor = Gat::Executor.new(@service, @spreadsheet_id)

        executor.upload_to_google_sheets([%w[hello2 thi2s is2 a2 test2], %w[hello this is a test]])
      end
    end
  end

  context "Huge file" do
    before do
      @sheet_id = "1EsjNcHASX7AD7JoejPojMMsPVdYUNwHFiNOsgKqkQ0w"
      @config = Gat::Config.new
      VCR.use_cassette("executor_huge_file_1_setup") do
        Gat::Setup.call(@config.sheet_service, @sheet_id)
      end
      @service = @config.sheet_service
      @spreadsheet_id = @sheet_id
      @data = gen_big_csv(3000)
    end
    it "uploads the report to Google Sheets" do
      VCR.use_cassette("executor_huge_file_1") do
        executor = Gat::Executor.new(@service, @spreadsheet_id)

        executor.upload_to_google_sheets(@data)
      end



      VCR.use_cassette("executor_huge_file_1_read") do
        lens = Gat::Lens.new(@service, @spreadsheet_id)

        inspect = lens.inspect()
        expect(inspect[0][:title]).to eq("Sheet1")
        expect(inspect[1][:title]).to eq("status")
        expect(inspect[2][:title]).to eq("System export")
        # report = lens.read(Gat::Executor::REPORT_SHEET_NAME)
        # expect(report).to eq([@data[0..5]])
        # status = lens.read("Status")
        # expect(status[0][0]).to eq("THIS SPREADSHEET IS AUTOMATICALLY GENERATED BY THE SELMA SYSTEM. DO NOT MANUALLY EDIT THIS SPREADSHEET.")
        # expect(status[1][0]).to match("Data uploaded successfully on")
      end
    end

    it "Try rerun executor" do
      VCR.use_cassette("executor_huge_file_1_rewrite") do
        executor = Gat::Executor.new(@service, @spreadsheet_id)

        executor.upload_to_google_sheets(gen_big_csv(1600))
      end
    end
  end
end
