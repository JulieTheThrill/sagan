require 'spec_helper'

describe Sagan::Deploy::Up, '#run' do
  context 'when there are experimental remotes' do
    before do
      stub_remotes('exp1', 'exp2')
      stub_unavailable_server('exp1')
      stub_available_server('exp2')
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

      expect(output[1]).to eq "deploying to exp2\n"
    end

    it 'sets the experimental server to unavailable' do
      capture_stdout do
        deploy.run
      end

      expect(heroku).to have_received(:set_config)
        .with('EXPERIMENTAL_AVAILABLE', false, 'exp2')
    end

    it 'turns maintenance on before pushing' do
      heroku.stub(:maintenance_on).ordered
      git.stub(:force_push).ordered

      capture_stdout do
        deploy.run
      end

      expect(heroku).to have_received(:maintenance_on).with('exp2')
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
      heroku.stub(:reset_db)

      output = capture_stdout do
        deploy.run
      end

      expect(heroku).to have_received(:reset_db).with('exp2')
      expect(output).to include 'Resetting database'
    end

    it 'turns maintenance off after the database has been reset' do
      heroku.stub(:reset_db).ordered
      heroku.stub(:maintenance_off).ordered

      capture_stdout do
        deploy.run
      end

      expect(heroku).to have_received(:reset_db)
      expect(heroku).to have_received(:maintenance_off).with('exp2')
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

  def heroku
    @heroku ||= Sagan::Mocks::Heroku.new
  end

  def deploy
    @deploy ||= Sagan::Deploy::Up.new(git, heroku)
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
