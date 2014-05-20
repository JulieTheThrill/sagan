require 'spec_helper'

describe Sagan::Git, '#current_branch' do
  it 'returns the current git branch' do
    git = Sagan::Git.new
    expect(git).to receive(:`).
      with('git rev-parse --abbrev-ref HEAD').
      and_return("cool-feature\n")

    expect(git.current_branch).to eq 'cool-feature'
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

describe Sagan::Git, '#force_push' do
  it 'force pushes the current HEAD to the given remote' do
    git = Sagan::Git.new
    git.stub(:`)

    git.force_push('aremote')

    expect(git).to have_received(:`).with('git push aremote HEAD:master -f')
  end
end
