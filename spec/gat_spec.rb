# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat do
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
    @report.update([%(example test hello), [1, 2, 3]])
    values = @report.inspect
    expect(values[0]).to eq(%(example test hello))
    expect(values[1]).to eq([1, 2, 3])
  end

  xit "#share!" do
    @report.share!
  end
end
