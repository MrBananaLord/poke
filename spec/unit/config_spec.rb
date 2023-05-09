# frozen_string_literal: true

require 'poke/config'

RSpec.describe Poke::Config do
  let(:tmp_config_path) { './.poke.json' }
  let(:tmp_root_path) { './.poke' }

  before do
    stub_const('Poke::Config::PATH', tmp_config_path)
    stub_const('Poke::Config::DEFAULT_ROOT_PATH', tmp_root_path)

    described_class.instance_variable_set :@all, nil
  end

  describe '.all' do
    context 'without the config file' do
      it 'returns default config hash' do
        expect(described_class.all).to eq({ 'root_path' => tmp_root_path })
      end
    end

    context 'with config file' do
      let(:config) { { 'root_path' => '/foo/bar/baz', 'faz' => 'baz' } }

      before { File.write(tmp_config_path, config.to_json) }
      after { File.delete(tmp_config_path) }

      it 'returns config loaded from the file' do
        expect(described_class.all).to eq(config)
      end
    end
  end

  describe '.root_path' do
    before { allow(described_class).to receive(:all).and_return({ 'root_path' => '/foo' }) }

    it 'returns the root_path from the config' do
      expect(described_class.root_path).to eq('/foo')
    end
  end
end
