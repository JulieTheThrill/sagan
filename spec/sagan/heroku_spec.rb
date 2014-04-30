require 'spec_helper'

describe Sagan::Heroku, '#lock' do
  it 'sets the deployment lock environment variable on the server' do
    heroku = Sagan::Heroku.new
    heroku.stub(:`)

    heroku.lock('aremote')

    expect(heroku).to have_received(:`)
      .with('heroku config:set EXPERIMENTAL_AVAILABLE=false -r aremote')
  end
end

describe Sagan::Heroku, '#unlock' do
  it 'sets the deployment unlock environment variable on the server' do
    heroku = Sagan::Heroku.new
    heroku.stub(:`)

    heroku.unlock('aremote')

    expect(heroku).to have_received(:`)
      .with('heroku config:set EXPERIMENTAL_AVAILABLE=true -r aremote')
  end
end

describe Sagan::Heroku, '#unlocked?' do
  context 'when the environment variable is true' do
    it 'returns the config key from the remote' do
      stub_unlocked('true\n')

      expect(heroku.unlocked?('aremote')).to eq true
    end
  end

  context 'when the environment variable is not true' do
    it 'returns the config key from the remote' do
      stub_unlocked

      expect(heroku.unlocked?('aremote')).to eq false
    end
  end

  def heroku
    @heroku ||= Sagan::Heroku.new
  end

  def stub_unlocked(value = nil)
    heroku.stub(:`)
      .with('heroku config:get EXPERIMENTAL_AVAILABLE -r aremote')
      .and_return(value)
  end
end

describe Sagan::Heroku, '#maintenance_off' do
  it 'disables heroku maintenance' do
    heroku = Sagan::Heroku.new
    heroku.stub(:`)

    heroku.maintenance_off('exp2')

    expect(heroku).to have_received(:`)
      .with('heroku maintenance:off -r exp2')
  end
end

describe Sagan::Heroku, '#maintenance_on' do
  it 'enables heroku maintenance' do
    heroku = Sagan::Heroku.new
    heroku.stub(:`)

    heroku.maintenance_on('exp2')

    expect(heroku).to have_received(:`)
      .with('heroku maintenance:on -r exp2')
  end
end

describe Sagan::Heroku, '#reset_db' do
  it 'resets, migrates and seeds the database on the given server' do
    heroku = Sagan::Heroku.new

    expect(heroku).to receive(:`)
      .with('heroku pg:reset DATABASE --confirm schoolkeep-experimental-1000 -r exp1000')
      .ordered
    expect(heroku).to receive(:`)
      .with('heroku run rake db:migrate db:seed -r exp1000')
      .ordered
    expect(heroku).to receive(:`)
      .with('heroku restart -r exp1000')
      .ordered

    heroku.reset_db('exp1000')
  end
end

