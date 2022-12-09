# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat::Executor do
  it "round_trip" do
    VCR.use_cassette("executor_example_1") do
      Gat::Setup.call
      executor = Gat::Executor.new

      executor.upload_to_google_sheets([%w[hello this is a test], %w[hello this is a test]])
    end
  end
end
