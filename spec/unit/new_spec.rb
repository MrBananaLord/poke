require 'tmpdir'
require 'fileutils'

require 'poke/commands/new'

RSpec.describe Poke::Commands::New do
  let(:output) { StringIO.new }
  let(:errors) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:root) { Dir.mktmpdir }

  before do
    allow(Poke::Config).to receive(:valid?).and_return(true)
    allow(Poke::Config).to receive(:root_path).and_return(root)
    allow(TTY::Prompt).to receive(:new).with(interrupt: :exit).and_return(prompt)
    allow(TTY::Editor).to receive(:open)
  end

  after do
    FileUtils.remove_entry(root)
  end

  def run_command
    described_class.new.send(:run, output: output, errors: errors)
  end

  it 'creates request in selected existing directory' do
    Dir.mkdir(File.join(root, 'api'))
    selected_dir = File.join(root, 'api')

    allow(prompt).to receive(:select).and_return(selected_dir)
    allow(prompt).to receive(:ask).with('Request name', required: true).and_return('list_users')

    run_command

    request_path = File.join(selected_dir, 'list_users.curl')
    expect(File).to exist(request_path)
    expect(File.read(request_path)).to eq("curl $BASE_URL/get -G -d foo=bar\n")
    expect(TTY::Editor).to have_received(:open).with(request_path)
    expect(output.string).to include("Created request: #{request_path}")
  end

  it 'creates nested directory when user chooses create directory option' do
    allow(prompt).to receive(:select).and_return(described_class::CREATE_NEW_DIR)
    allow(prompt).to receive(:ask).with('New directory path under ~/.poke', required: true).and_return('payments/refunds')
    allow(prompt).to receive(:ask).with('Request name', required: true).and_return('create_refund')

    run_command

    request_path = File.join(root, 'payments/refunds/create_refund.curl')
    expect(File).to exist(request_path)
    expect(File.read(request_path)).to eq("curl $BASE_URL/get -G -d foo=bar\n")
  end

  it 'rejects directory traversal outside ~/.poke' do
    allow(prompt).to receive(:select).and_return(described_class::CREATE_NEW_DIR)
    allow(prompt).to receive(:ask).with('New directory path under ~/.poke', required: true).and_return('../outside')

    run_command

    expect(errors.string).to include('Path must stay inside ~/.poke')
    expect(Dir.glob(File.join(root, '**', '*.curl'))).to be_empty
  end

  it 'does not overwrite existing file without confirmation' do
    Dir.mkdir(File.join(root, 'users'))
    selected_dir = File.join(root, 'users')
    request_path = File.join(selected_dir, 'show_user.curl')
    File.write(request_path, "curl $BASE_URL/post\n")

    allow(prompt).to receive(:select).and_return(selected_dir)
    allow(prompt).to receive(:ask).with('Request name', required: true).and_return('show_user')
    allow(prompt).to receive(:yes?).with('Request exists. Overwrite?').and_return(false)

    run_command

    expect(File.read(request_path)).to eq("curl $BASE_URL/post\n")
    expect(output.string).to include('Canceled.')
    expect(TTY::Editor).not_to have_received(:open)
  end
end
