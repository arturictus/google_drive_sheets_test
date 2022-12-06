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

  it "#read" do
    expect(@report.read).to be_a(Google::Apis::SheetsV4::Spreadsheet)
  end

  it "updating sheets" do
    @report
    # byebug
  end

  it "#share!" do
    @report.share!
  end
end
