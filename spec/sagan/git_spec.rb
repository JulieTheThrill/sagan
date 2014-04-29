require 'spec_helper'

describe Sagan::Git, '#force_push' do
  it 'force pushes the current HEAD to the given remote' do
    git = Sagan::Git.new
    git.stub(:`)

    git.force_push('aremote')

    expect(git).to have_received(:`).with('git push aremote HEAD:master -f')
  end
end

describe Sagan::Git, '#remotes' do
  it 'returns the list of git remotes for the current working directory' do
    git = Sagan::Git.new
    git.stub(:`)

    git.remotes

    expect(git).to have_received(:`).with('git remote')
  end
end
