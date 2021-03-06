require 'spec_helper'

describe NiftySettings::Settings do
  let(:nested_settings_hash) { { pelle: 'fant', shnoo: 'shnaa' } }
  let(:settings_hash)        { { foo: 'bar', nested: nested_settings_hash, really?: true, not_really?: false, nothing?: nil } }
  let(:settings)             { NiftySettings::Settings.new(settings_hash) }
  let(:empty_settings)       { NiftySettings::Settings.new }

  context 'comparing two settings' do
    it 'works as expected' do
      expect(NiftySettings::Settings.new(settings_hash)).to     be == NiftySettings::Settings.new(settings_hash)
      expect(NiftySettings::Settings.new(settings_hash)).to_not be == NiftySettings::Settings.new(nested_settings_hash)
      expect(NiftySettings::Settings.new(settings_hash)).to_not be == 'random string'
    end
  end

  context '#key' do
    context 'when no setting with that key exists' do
      it 'returns nil' do
        expect(settings.not_found).to be_nil
      end

      it 'does not change the settings' do
        expect { settings.not_found }.to_not change { settings.to_h }
      end
    end

    context 'when the settings has a single value' do
      it 'returns the value' do
        expect(settings.foo).to eq('bar')
      end
    end

    context 'when the setting has nested values' do
      it 'returns a settings object with the values' do
        expect(settings.nested).to eq(NiftySettings::Settings.new(nested_settings_hash))
      end
    end
  end

  describe '#to_s' do
    context 'when no settings are stored' do
      it 'returns an empty string' do
        expect(empty_settings.to_s).to eq('')
      end
    end

    context 'when settings are stored' do
      it 'returns a string representation of the settings' do
        expect(settings.to_s).to eq(settings_hash.to_s)
      end
    end
  end

  describe '#key?' do
    context 'when no setting with that key exists' do
      it 'returns false' do
        expect(settings.bar?).to eq(false)
      end
    end

    context 'when the settings has a single value' do
      it 'returns true' do
        expect(settings.foo?).to eq(true)
      end
    end

    context 'when the settings has key ending with ?' do
      it 'returns true' do
        expect(settings.really?).to eq(true)
      end

      it 'returns false' do
        expect(settings.not_really?).to eq(false)
      end

      it 'returns nil' do
        expect(settings.nothing?).to be_nil
      end
    end

    context 'when the setting has nested values' do
      it 'returns true' do
        expect(settings.nested?).to eq(true)
      end
    end
  end

  describe '.load_from_file' do
    it 'loads the settings from the default location' do
      # Reset settings path in case it has been modified
      NiftySettings::Settings.settings_path = nil

      # Copy settings file to default location
      settings_file         = File.expand_path('../../support/settings.yml', __FILE__)
      default_settings_file = File.expand_path('../../../config/settings.yml', __FILE__)
      FileUtils.mkdir_p File.dirname(default_settings_file)
      FileUtils.cp settings_file, default_settings_file

      settings = NiftySettings::Settings.load_from_file
      expect(settings).to eq('foo' => 'bar')

      # Delete settings file again
      FileUtils.rm default_settings_file
    end

    it 'can load the settings from a custom location' do
      NiftySettings::Settings.settings_path = File.expand_path('../../support/settings.yml', __FILE__)
      settings = NiftySettings::Settings.load_from_file
      expect(settings).to eq('foo' => 'bar')
    end

    it 'can load empty settings' do
      NiftySettings::Settings.settings_path = File.expand_path('../../support/settings_empty.yml', __FILE__)
      settings = NiftySettings::Settings.load_from_file
      expect(settings).to eq({})
    end
  end
end
