RSpec.describe "`poke curl` command", type: :cli do
  it "executes `poke help curl` command successfully" do
    output = `poke help curl`
    expected_output = <<-OUT
Usage:
  poke curl FILE

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
