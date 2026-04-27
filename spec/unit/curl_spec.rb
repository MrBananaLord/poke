require 'json'

require 'poke/commands/curl'

RSpec.describe Poke::Commands::Curl do
  let(:output) { StringIO.new }
  let(:errors) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:tty_command) { instance_double(TTY::Command) }
  let(:table) { instance_double(TTY::Table, render: 'TABLE') }
  let(:pastel) { double('PastelInstance') }
  let(:group_config) do
    instance_double(
      Poke::GroupConfig,
      default_env: 'dev',
      valid_env?: true,
      variables: { 'BASE_URL' => 'https://example.test' }
    )
  end
  let(:group) { instance_double(Poke::Group, config: group_config) }
  let(:request) do
    instance_double(
      Poke::Request,
      position: 0,
      name_with_alias: 'group/users/get',
      name: 'group/users/get',
      path: '/tmp/group/users/get.curl',
      group: group
    )
  end

  before do
    errors.define_singleton_method(:tty?) { true }

    allow(TTY::Prompt).to receive(:new).with(interrupt: :exit, output: errors).and_return(prompt)
    allow(prompt).to receive(:select).and_return('group/users/get')

    allow(Poke::Request).to receive(:all).and_return([request])
    allow(Poke::Request).to receive(:find_by_name_with_alias).with('group/users/get').and_return(request)

    allow(request).to receive(:use!)
    allow(group).to receive(:use!)

    allow(TTY::Table).to receive(:new).and_return(table)
    allow(TTY::Command).to receive(:new).with(printer: :null).and_return(tty_command)

    allow(Pastel).to receive(:new).and_return(pastel)
    allow(pastel).to receive(:decorate) { |text, _color| text }
  end

  def run_command(options = {})
    described_class.new(options).send(:run, output: output, errors: errors)
  end

  it 'keeps interactive selection off stdout and prints response body to stdout' do
    stats = {
      'response_code' => 200,
      'size_download' => 10,
      'time_appconnect' => 0.001,
      'time_connect' => 0.001,
      'time_namelookup' => 0.001,
      'time_pretransfer' => 0.001,
      'time_redirect' => 0.0,
      'time_starttransfer' => 0.002,
      'time_total' => 0.003,
      'url' => 'https://example.test/users',
      'filename_effective' => '/tmp/response.json'
    }
    command_result = instance_double(TTY::Command::Result, failure?: false, err: 'curl-metrics', out: JSON.generate(stats))
    allow(tty_command).to receive(:run!).and_return(command_result)
    allow(Poke::Config).to receive(:response_path).and_return('/tmp/response.json')
    allow(File).to receive(:read).with('/tmp/response.json').and_return('{"ok":true}')
    allow_any_instance_of(described_class).to receive(:build_command).and_return(['curl test', 'comment'])

    run_command

    expect(output.string).to eq("\n{\"ok\":true}\n")
    expect(errors.string).to include('TABLE')
    expect(errors.string).to include('curl-metrics')
    expect(TTY::Prompt).to have_received(:new).with(interrupt: :exit, output: errors)
  end

  it 'writes command failure details to stderr not stdout' do
    command_result = instance_double(TTY::Command::Result, failure?: true, err: 'curl failed', out: '{}')
    allow(tty_command).to receive(:run!).and_return(command_result)
    allow_any_instance_of(described_class).to receive(:build_command).and_return(['curl test', 'comment'])
    allow(Poke::Paint).to receive(:farewell).and_return("bye\n")

    run_command

    expect(output.string).to eq('')
    expect(errors.string).to include('curl failed')
    expect(errors.string).to include('bye')
  end
end
