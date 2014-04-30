require 'spec_helper'

describe Sagan::Git, '#force_push' do
  it 'force pushes the current HEAD to the given remote' do
    git = Sagan::Git.new
    git.stub(:`)

    git.force_push('aremote')

    expect(git).to have_received(:`).with('git push aremote HEAD:master -f')
  end
end

describe Sagan::Git, '#experimental_remotes' do
  it 'returns the list of git remotes for the current working directory' do
    git = Sagan::Git.new
    remotes = "origin\nexp1\nexp2\n"
    expect(git).to receive(:`).with('git remote').and_return(remotes)

    expect(git.experimental_remotes).to eq ['exp1', 'exp2']
  end
end
