module Sagan
  class Git
    def force_push(remote)
      `git push #{remote} HEAD:master -f`
    end

    def remotes
      `git remote`
    end
  end
end
