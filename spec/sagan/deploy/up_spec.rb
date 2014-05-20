require 'spec_helper'

describe Sagan::Deploy::Up, '#run' do
  context 'when there are experimental remotes' do
    before do
      remotes = ['exp1', 'exp2']
      stub_remotes(*remotes)
      stub_servers(*remotes)
    end

    it 'displays a message with the current branch for the unavailable server' do
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
      available_server.stub(:lock)

      capture_stdout do
        deploy.run
      end

      expect(available_server).to have_received(:lock)
    end

    it 'turns maintenance on before pushing' do
      available_server.stub(:maintenance_on).ordered
      git.stub(:force_push).ordered

      capture_stdout do
        deploy.run
      end

      expect(available_server).to have_received(:maintenance_on)
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
      available_server.stub(:reset_db)

      output = capture_stdout do
        deploy.run
      end

      expect(available_server).to have_received(:reset_db)
      expect(output).to include 'Resetting database'
    end

    it 'turns maintenance off after the database has been reset' do
      available_server.stub(:reset_db).ordered
      available_server.stub(:maintenance_off).ordered

      capture_stdout do
        deploy.run
      end

      expect(available_server).to have_received(:reset_db)
      expect(available_server).to have_received(:maintenance_off)
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

  def servers
    @servers
  end

  def available_server
    @available_server
  end

  def unavailable_server
    @unavailable_server
  end

  def server_type
    Sagan::Mocks::Heroku
  end

  def deploy
    @deploy ||= Sagan::Deploy::Up.new(git, server_type)
  end

  def stub_remotes(*remotes)
    git.stub(:experimental_remotes).and_return(remotes)
  end

  def stub_servers(*args)
    @servers = args.map do |remote|
      server_type.new(remote)
    end
    server_type.stub(:new).and_return do |remote|
      @servers.detect { |r| r.remote == remote }
    end

    stub_unavailable_server(@servers[0])
    stub_available_server(@servers[1])
    @unavailable_server = @servers[0]
    @available_server = @servers[1]
  end

  def stub_unavailable_server(server)
    server.stub(:unlocked?).and_return(false)
  end

  def stub_available_server(server)
    server.stub(:unlocked?).and_return(true)
  end
end
