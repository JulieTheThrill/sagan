module Sagan
  class Git
    def current_branch
      git("rev-parse --abbrev-ref HEAD").chop
    end

    def experimental_remotes
      remotes.select { |r| r =~ /^exp\d+$/ }
    end

    def force_push(remote)
      git("push #{remote} HEAD:master -f")
    end

    private

    def git(cmd)
      Bundler.with_clean_env do
        `git #{cmd}`
      end
    end

    def remotes
      @remotes ||= git('remote').split("\n")
    end
  end
end
