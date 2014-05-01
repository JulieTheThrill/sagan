require 'spec_helper'

describe Sagan::Deploy::Up, '#run' do
  context 'when there are experimental remotes' do
    before do
      remotes = ['exp1', 'exp2']
      stub_remotes(*remotes)
      stub_heroku_servers(*remotes)
      stub_unavailable_server(heroku_servers[0])
      stub_available_server(heroku_servers[1])
    end

    it 'displays a message for the unavailable server' do
      output = capture_stdout_lines do
        deploy.run
      end

      expect(output[0]).to eq "exp1 is unavailable\n"
    end

    it 'displays a deploy message for the open server' do
      output = capture_stdout_lines do
        deploy.run
      end

      expect(output[1]).to eq "Deploying to exp2\n"
    end

    it 'sets the experimental server to unavailable' do
      heroku_remote = heroku_servers[1]
      heroku_remote.stub(:lock)

      capture_stdout do
        deploy.run
      end

      expect(heroku_remote).to have_received(:lock)
    end

    it 'turns maintenance on before pushing' do
      heroku_remote = heroku_servers[1]
      heroku_remote.stub(:maintenance_on).ordered
      git.stub(:force_push).ordered

      capture_stdout do
        deploy.run
      end

      expect(heroku_remote).to have_received(:maintenance_on)
      expect(git).to have_received(:force_push)
    end

    it 'force pushes to the open server' do
      git.stub(:force_push)

      capture_stdout do
        deploy.run
      end

      expect(git).to have_received(:force_push).with('exp2')
    end

    it 'resets the database on the open server' do
      heroku_remote = heroku_servers[1]
      heroku_remote.stub(:reset_db)

      output = capture_stdout do
        deploy.run
      end

      expect(heroku_remote).to have_received(:reset_db)
      expect(output).to include 'Resetting database'
    end

    it 'turns maintenance off after the database has been reset' do
      heroku_remote = heroku_servers[1]
      heroku_remote.stub(:reset_db).ordered
      heroku_remote.stub(:maintenance_off).ordered

      capture_stdout do
        deploy.run
      end

      expect(heroku_remote).to have_received(:reset_db)
      expect(heroku_remote).to have_received(:maintenance_off)
    end

    it 'displays a success message' do
      output = capture_stdout do
        deploy.run
      end

      expect(output).to include 'Successfully deployed to http://www.exp2.schoolify.me'
    end
  end

  context "when there aren't any experimental remotes" do
    before { stub_remotes }

    it 'displays an error message' do
      output = capture_stdout_lines do
        deploy.run
      end

      expect(output[0]).to eq "You don't have any experimental git remotes\n"
      expect(output[1]).to eq "Please add exp[1-n]\n"
    end
  end

  def git
    @git ||= Sagan::Mocks::Git.new
  end

  def heroku_servers
    @heroku_servers
  end

  def deploy
    @deploy ||= Sagan::Deploy::Up.new(git, Sagan::Mocks::Heroku)
  end

  def stub_remotes(*remotes)
    git.stub(:experimental_remotes).and_return(remotes)
  end

  def stub_heroku_servers(*args)
    @heroku_servers = args.map do |remote|
      Sagan::Mocks::Heroku.new(remote)
    end
    Sagan::Mocks::Heroku.stub(:new).and_return do |remote|
      @heroku_servers.detect { |r| r.remote == remote }
    end
  end

  def stub_unavailable_server(heroku_remote)
    heroku_remote.stub(:unlocked?).and_return(false)
  end

  def stub_available_server(heroku_remote)
    heroku_remote.stub(:unlocked?).and_return(true)
  end
end
