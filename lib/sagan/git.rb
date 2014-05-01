module Sagan
  class Git
    def force_push(remote)
      git("push #{remote} HEAD:master -f")
    end

    def experimental_remotes
      remotes.select { |r| r =~ /^exp\d+$/ }
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
