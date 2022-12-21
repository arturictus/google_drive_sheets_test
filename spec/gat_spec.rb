# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Gat do
  it "has a version number" do
    expect(Gat::VERSION).not_to be nil
  end
  xit "#share!" do
    @report.share!
  end

  def do_chunk(data)
    data.each_slice(1000).reduce(1) do |counter, chunk|
      puts "|---------------- chunk start"
      puts "#{chunk[0][0]}...#{chunk[-1][-1]}"
      # puts chunk.to_json
      puts do_range(counter, counter + chunk.size - 1)
      counter + chunk.size
    end
  end

  def do_range(init, last)
    "A#{init}:Z#{last}"
  end
  it "investigate chunk" do
    data = gen_big_csv(3000)
    do_chunk(data)

    do_chunk([[1],[2]])
  end
end
