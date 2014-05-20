require 'spec_helper'

describe Sagan::Heroku, '#deployed_branch' do
  it 'returns the deployed branch environment variable' do
    heroku = Sagan::Heroku.new('aremote')
    allow(heroku).to receive(:`).
      with('heroku config:get SAGAN_BRANCH -r aremote').
      and_return('cool-feature')

    expect(heroku.deployed_branch).to eq 'cool-feature'
  end
end

describe Sagan::Heroku, '#set_deployed_branch' do
  it 'sets the deployed branch in an environment variable' do
    heroku = Sagan::Heroku.new('aremote')
    allow(heroku).to receive(:`)

    heroku.set_deployed_branch('cool-feature')

    cmd = 'heroku config:set SAGAN_BRANCH=cool-feature -r aremote'
    expect(heroku).to have_received(:`).with(cmd)
  end
end

describe Sagan::Heroku, '#lock' do
  it 'sets the deployment lock environment variable on the server' do
    heroku = Sagan::Heroku.new('aremote')
    allow(heroku).to receive(:`)

    heroku.lock

    expect(heroku).to have_received(:`)
      .with('heroku config:set EXPERIMENTAL_AVAILABLE=false -r aremote')
  end
end

describe Sagan::Heroku, '#unlock' do
  it 'sets the deployment unlock environment variable on the server' do
    heroku = Sagan::Heroku.new('aremote')
    allow(heroku).to receive(:`)

    heroku.unlock

    expect(heroku).to have_received(:`)
      .with('heroku config:set EXPERIMENTAL_AVAILABLE=true -r aremote')
  end
end

describe Sagan::Heroku, '#unlocked?' do
  context 'when the environment variable is true' do
    it 'returns the config key from the remote' do
      stub_unlocked('true\n')

      expect(heroku.unlocked?).to eq true
    end
  end

  context 'when the environment variable is not true' do
    it 'returns the config key from the remote' do
      stub_unlocked

      expect(heroku.unlocked?).to eq false
    end
  end

  def heroku
    @heroku ||= Sagan::Heroku.new('aremote')
  end

  def stub_unlocked(value = nil)
    allow(heroku).to receive(:`)
      .with('heroku config:get EXPERIMENTAL_AVAILABLE -r aremote')
      .and_return(value)
  end
end

describe Sagan::Heroku, '#maintenance_off' do
  it 'disables heroku maintenance' do
    heroku = Sagan::Heroku.new('exp2')
    allow(heroku).to receive(:`)

    heroku.maintenance_off

    expect(heroku).to have_received(:`)
      .with('heroku maintenance:off -r exp2')
  end
end

describe Sagan::Heroku, '#maintenance_on' do
  it 'enables heroku maintenance' do
    heroku = Sagan::Heroku.new('exp2')
    allow(heroku).to receive(:`)

    heroku.maintenance_on

    expect(heroku).to have_received(:`)
      .with('heroku maintenance:on -r exp2')
  end
end

describe Sagan::Heroku, '#reset_db' do
  it 'resets, migrates and seeds the database on the given server' do
    heroku = Sagan::Heroku.new('exp1000')

    expect(heroku).to receive(:`)
      .with('heroku pg:reset DATABASE --confirm schoolkeep-experimental-1000 -r exp1000')
      .ordered
    expect(heroku).to receive(:`)
      .with('heroku run rake db:migrate db:seed -r exp1000')
      .ordered
    expect(heroku).to receive(:`)
      .with('heroku restart -r exp1000')
      .ordered

    heroku.reset_db
  end
end

