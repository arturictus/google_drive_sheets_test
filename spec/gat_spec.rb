# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat do
  it "has a version number" do
    expect(Gat::VERSION).not_to be nil
  end

  before do
    @sheet = Gat::Sheet.new
    @sheet.init
  end
  it "#sheet" do
    expect(@sheet.sheet).to be_a(Google::Apis::SheetsV4::Spreadsheet)
  end

  it "#read" do
    expect(@sheet.read).to be_a(Google::Apis::SheetsV4::BatchGetValuesResponse)
  end

  it "#share!" do
    @sheet.share!
  end
end
