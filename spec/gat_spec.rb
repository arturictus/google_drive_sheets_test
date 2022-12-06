# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat do
  it "has a version number" do
    expect(Gat::VERSION).not_to be nil
  end

  it "sets the spreadsheet" do
    sheet = Gat::Sheet.new
    out = sheet.call()
    expect(out).to be_a(Google::Apis::SheetsV4::Spreadsheet)
  end
end
