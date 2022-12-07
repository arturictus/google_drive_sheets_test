# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat::ReportV2 do
  it "round_trip" do
    VCR.use_cassette("the_whole_thing") do
      Gat::Report.new.init
      report = Gat::ReportV2.new

      report.upload_to_google_sheets([%w[hello this is a test], %w[hello this is a test]])
    end
  end
end
