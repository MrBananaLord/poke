require 'poke/commands/curl'

RSpec.describe Poke::Commands::Curl do
  it "executes `curl` command successfully" do
    output = StringIO.new
    file = nil
    options = {}
    command = Poke::Commands::Curl.new(file, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
