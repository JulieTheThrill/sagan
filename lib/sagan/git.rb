module Sagan
  class Git
    def force_push(remote)
      `git push #{remote} HEAD:master -f`
    end

    def experimental_remotes
      remotes.select { |r| r =~ /^exp\d+$/ }
    end

    private

    def remotes
      @remotes ||= (`git remote`).split("\n")
    end
  end
end
