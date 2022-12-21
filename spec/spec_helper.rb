# frozen_string_literal: true

require "gat"
require "byebug"
require "webmock"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "./spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def gen_big_csv(num)
  data = []
  (1...num).each do |r|
    col = []
    10.times do |c|
      col << "#{r}.#{c}"
    end
    data << col
  end
  data
end
