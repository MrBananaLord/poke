require 'poke/commands/env'

RSpec.describe Poke::Commands::Env do
  it "executes `env` command successfully" do
    output = StringIO.new
    options = {}
    command = Poke::Commands::Env.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
