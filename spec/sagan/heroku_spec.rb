require 'spec_helper'

describe Sagan::Heroku, '#reset_db' do
  it 'resets, migrates and seeds the database on the given remote' do
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

describe Sagan::Heroku, '#get_config' do
  it 'returns the config key from the remote' do
    value = double(:value)
    heroku = Sagan::Heroku.new
    heroku.stub(:`).with('heroku config:get KEY -r aremote').and_return(value)

    config = heroku.get_config('KEY', 'aremote')

    expect(config).to eq value
  end
end

describe Sagan::Heroku, '#set_config' do
  it 'sets the given config key and value on the remote' do
    heroku = Sagan::Heroku.new
    heroku.stub(:`)

    heroku.set_config('KEY', 'VALUE', 'aremote')

    expect(heroku).to have_received(:`)
      .with('heroku config:set KEY=VALUE -r aremote')
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

describe Sagan::Heroku, '#maintenance_off' do
  it 'disables heroku maintenance' do
    heroku = Sagan::Heroku.new
    heroku.stub(:`)

    heroku.maintenance_off('exp2')

    expect(heroku).to have_received(:`)
      .with('heroku maintenance:off -r exp2')
  end
end
