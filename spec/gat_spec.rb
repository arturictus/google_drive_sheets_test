# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat do # rubocop:disable Metrics/BlockLength
  it "has a version number" do
    expect(Gat::VERSION).not_to be nil
  end

  before do
    @report = Gat::Report.new
    @report.init
  end
  it "#spreadsheet" do
    expect(@report.spreadsheet).to be_a(Google::Apis::SheetsV4::Spreadsheet)
  end

  it "mark_as_updating" do
    @report.mark_as_updating
    values = @report.inspect
    puts values.to_json
    expect(values[0].count).to eq(1)
    expect(values[1].count).to eq(1)
    expect(values[0][0]).to match("THIS")
    expect(values[1][0]).to match("Uploading")
  end

  it "#read" do
    expect(@report.read).to be_a(Google::Apis::SheetsV4::Spreadsheet)
  end

  it "#inspect" do
    @report.inspect
  end

  it "updating sheets" do
    data = [%w[example test hello], %w[1 2 3]]
    @report.update(data)
    values = @report.inspect(Gat::Report::REPORT_SHEET)
    expect(values[0]).to eq(data[0])
    expect(values[1]).to eq(data[1])

    data2 = [%w[example2 test2 hello2], %w[1_ 2_ 3_]]
    @report.update(data2)
    values2 = @report.inspect(Gat::Report::REPORT_SHEET)
    expect(values2[0]).to eq(data2[0])
    expect(values2[1]).to eq(data2[1])
  end

  xit "#share!" do
    @report.share!
  end
end
