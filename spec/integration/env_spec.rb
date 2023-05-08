RSpec.describe "`poke env` command", type: :cli do
  it "executes `poke help env` command successfully" do
    output = `poke help env`
    expected_output = <<-OUT
Usage:
  poke env

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
