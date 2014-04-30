require 'spec_helper'

describe Sagan::Deploy::Down, '#run' do
  context 'when the remote exists' do
    before do
      stub_remotes('exp1')
    end

    it 'displays a start message' do
      output = capture_stdout_lines do
        deploy.down('exp1')
      end

      expect(output[0]).to eq "Unlocking exp1\n"
    end

    it 'sets the experimental server to available' do
      heroku.stub(:set_config)

      capture_stdout do
        deploy.down('exp1')
      end

      expect(heroku).to have_received(:set_config)
        .with('EXPERIMENTAL_AVAILABLE', true, 'exp1')
    end

    it 'turns maintenance on' do
      heroku.stub(:maintenance_on)

      capture_stdout do
        deploy.down('exp1')
      end

      expect(heroku).to have_received(:maintenance_on).with('exp1')
    end

    it 'displays a success message' do
      output = capture_stdout_lines do
        deploy.down('exp1')
      end

      expect(output[1]).to eq "exp1 is now available for use\n"
    end
  end

  context 'when the remote is nil' do
    it 'displays the command usage instructions' do
      output = capture_stdout_lines do
        deploy.down(nil)
      end

      expect(output[0]).to eq "You must provide an experimental remote\n"
      expect(output[1]).to eq "rake exp:down[myremote]\n"
    end
  end

  context "when the experimental remote doesn't exist" do
    it 'displays an error message' do
      stub_remotes('exp1')

      output = capture_stdout_lines do
        deploy.down('exp2')
      end

      expect(output[0]).to eq "Experimental remote exp2 doesn't exist\n"
    end
  end

  def git
    @git ||= Sagan::Mocks::Git.new
  end

  def heroku
    @heroku ||= Sagan::Mocks::Heroku.new
  end

  def deploy
    @deploy ||= Sagan::Deploy::Down.new(git, heroku)
  end

  def stub_remotes(*remotes)
    git.stub(:experimental_remotes).and_return(remotes)
  end

  def stub_unavailable_server(remote)
    heroku.stub(:get_config)
      .with('EXPERIMENTAL_AVAILABLE', remote)
      .and_return("false\n")
    heroku.stub(:set_config)
  end

  def stub_available_server(remote)
    heroku.stub(:get_config)
      .with('EXPERIMENTAL_AVAILABLE', remote)
      .and_return("true\n")
  end
end
