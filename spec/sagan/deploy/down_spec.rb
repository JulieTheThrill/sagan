require 'spec_helper'

describe Sagan::Deploy::Down, '#initialize' do
  context 'when the remote is nil' do
    it 'displays the command usage instructions' do
      output = capture_stdout_lines do
        Sagan::Deploy::Down.new(nil)
      end

      expect(output[0]).to eq "You must provide an experimental remote\n"
      expect(output[1]).to eq "rake exp:down[myremote]\n"
    end
  end

  context 'when the remote is not nil' do
    it "doesn't display command usage instructions" do
      output = capture_stdout do
        Sagan::Deploy::Down.new('aremote')
      end

      expect(output).to be_empty
    end
  end
end

describe Sagan::Deploy::Down, '#run' do
  context 'when the remote exists' do
    before do
      stub_remotes('exp1')
      stub_heroku_server('exp1')
    end

    it 'displays a start message' do
      deploy = create_deploy('exp1')

      output = capture_stdout_lines do
        deploy.run
      end

      expect(output[0]).to eq "Unlocking exp1\n"
    end

    it 'sets the experimental server to available' do
      deploy = create_deploy('exp1')
      heroku_server.stub(:unlock)

      capture_stdout do
        deploy.run
      end

      expect(heroku_server).to have_received(:unlock)
    end

    it 'turns maintenance on' do
      deploy = create_deploy('exp1')
      heroku_server.stub(:maintenance_on)

      capture_stdout do
        deploy.run
      end

      expect(heroku_server).to have_received(:maintenance_on)
    end

    it 'displays a success message' do
      deploy = create_deploy('exp1')

      output = capture_stdout_lines do
        deploy.run
      end

      expect(output[1]).to eq "exp1 is now available for use\n"
    end
  end

  context "when the experimental remote doesn't exist" do
    it 'displays an error message' do
      deploy = create_deploy('exp2')
      stub_remotes('exp1')

      output = capture_stdout_lines do
        deploy.run
      end

      expect(output[0]).to eq "Experimental remote exp2 doesn't exist\n"
    end
  end

  def git
    @git ||= Sagan::Mocks::Git.new
  end

  def heroku_server
    @heroku_server
  end

  def create_deploy(remote)
    Sagan::Deploy::Down.new(remote, git, Sagan::Mocks::Heroku)
  end

  def stub_heroku_server(remote)
    @heroku_server = Sagan::Mocks::Heroku.new(remote)
    Sagan::Mocks::Heroku.stub(:new).with(remote).and_return(@heroku_server)
  end

  def stub_remotes(*remotes)
    git.stub(:experimental_remotes).and_return(remotes)
  end
end
