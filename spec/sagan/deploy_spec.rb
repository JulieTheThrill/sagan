require 'spec_helper'

describe Sagan::Deploy do
  describe '#up' do
    context 'when there are experimental remotes' do
      before do
        stub_remotes('exp1', 'exp2')
        stub_unavailable_server('exp1')
        stub_available_server('exp2')
      end

      it 'displays a message for the unavailable server' do
        output = capture_stdout_lines do
          deployment.up
        end

        expect(output[0]).to eq "exp1 is unavailable\n"
      end

      it 'displays a deploy message for the open server' do
        output = capture_stdout_lines do
          deployment.up
        end

        expect(output[1]).to eq "deploying to exp2\n"
      end

      it 'sets the experimental server to unavailable' do
        capture_stdout do
          deployment.up
        end

        expect(heroku).to have_received(:set_config)
          .with('EXPERIMENTAL_AVAILABLE', false, 'exp2')
      end

      it 'turns maintenance on before pushing' do
        heroku.stub(:maintenance_on).ordered
        git.stub(:force_push).ordered

        capture_stdout do
          deployment.up
        end

        expect(heroku).to have_received(:maintenance_on).with('exp2')
        expect(git).to have_received(:force_push)
      end

      it 'force pushes to the open server' do
        git.stub(:force_push)

        capture_stdout do
          deployment.up
        end

        expect(git).to have_received(:force_push).with('exp2')
      end

      it 'resets the database on the open server' do
        heroku.stub(:reset_db)

        output = capture_stdout do
          deployment.up
        end

        expect(heroku).to have_received(:reset_db).with('exp2')
        expect(output).to include 'Resetting database'
      end

      it 'turns maintenance off after the database has been reset' do
        heroku.stub(:reset_db).ordered
        heroku.stub(:maintenance_off).ordered

        capture_stdout do
          deployment.up
        end

        expect(heroku).to have_received(:reset_db)
        expect(heroku).to have_received(:maintenance_off).with('exp2')
      end

      it 'displays a success message' do
        output = capture_stdout do
          deployment.up
        end

        expect(output).to include 'Successfully deployed to http://www.exp2.schoolify.me'
      end
    end

    context "when there aren't any experimental remotes" do
      before do
        stub_remotes('origin')
      end

      it 'displays an error message' do
        output = capture_stdout_lines do
          deployment.up
        end

        expect(output[0]).to eq "You don't have any experimental git remotes\n"
        expect(output[1]).to eq "Please add exp[1-n]\n"
      end
    end
  end

  describe '#down' do
    context 'when the remote exists' do
      before do
        stub_remotes('exp1')
      end

      it 'displays a start message' do
        output = capture_stdout_lines do
          deployment.down('exp1')
        end

        expect(output[0]).to eq "Starting to make exp1 available\n"
      end

      it 'sets the experimental server to available' do
        heroku.stub(:set_config)

        capture_stdout do
          deployment.down('exp1')
        end

        expect(heroku).to have_received(:set_config)
          .with('EXPERIMENTAL_AVAILABLE', true, 'exp1')
      end

      it 'turns maintenance on' do
        heroku.stub(:maintenance_on)

        capture_stdout do
          deployment.down('exp1')
        end

        expect(heroku).to have_received(:maintenance_on).with('exp1')
      end

      it 'displays a success message' do
        output = capture_stdout_lines do
          deployment.down('exp1')
        end

        expect(output[1]).to eq "exp1 is now available for use\n"
      end
    end

    context 'when the remote is nil' do
      it 'displays the command usage instructions' do
        output = capture_stdout_lines do
          deployment.down(nil)
        end

        expect(output[0]).to eq "You must provide a remote to tear down\n"
        expect(output[1]).to eq "rake exp:down[myremote]\n"
      end
    end

    context "when the experimental remote doesn't exist" do
      it 'displays an error message' do
        stub_remotes('exp1')

        output = capture_stdout_lines do
          deployment.down('exp2')
        end

        expect(output[0]).to eq "Experimental remote exp2 doesn't exist\n"
      end
    end
  end

  def git
    @git ||= Sagan::Mocks::Git.new
  end

  def heroku
    @heroku ||= Sagan::Mocks::Heroku.new
  end

  def deployment
    @deployment ||= Sagan::Deploy.new(git, heroku)
  end

  def stub_remotes(*remotes)
    git.stub(:remotes).and_return(remotes.join("\n"))
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

  def capture_stdout(&block)
    old_stdout = $stdout
    $stdout = stdout = StringIO.new

    yield
    stdout.string
  ensure
    $stdout = old_stdout
  end

  def capture_stdout_lines(&block)
    capture_stdout(&block).lines("\n")
  end
end
