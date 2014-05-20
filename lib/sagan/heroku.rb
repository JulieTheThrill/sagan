module Sagan
  class Heroku
    DEPLOYED_BRANCH_KEY = 'SAGAN_BRANCH'
    EXP = 'exp'
    EXP_APP_BASE_NAME = 'schoolkeep-experimental-'
    LOCK_KEY = 'EXPERIMENTAL_AVAILABLE'
    LOCKED = 'false'
    UNLOCKED = 'true'

    attr_reader :remote

    def initialize(remote)
      @remote = remote
    end

    def deployed_branch
      get_config(DEPLOYED_BRANCH_KEY, remote)
    end

    def set_deployed_branch(branch)
      set_config(DEPLOYED_BRANCH_KEY, branch, remote)
    end

    def lock
      set_config(LOCK_KEY, LOCKED, remote)
    end

    def unlock
      set_config(LOCK_KEY, UNLOCKED, remote)
    end

    def unlocked?
      get_config(LOCK_KEY, remote).to_s.start_with?("true")
    end

    def maintenance_off
      heroku("maintenance:off", remote)
    end

    def maintenance_on
      heroku("maintenance:on", remote)
    end

    def reset_db
      app_name = remote.gsub(EXP, EXP_APP_BASE_NAME)

      heroku("pg:reset DATABASE --confirm #{app_name}", remote)
      heroku("run rake db:migrate db:seed", remote)
      heroku("restart", remote)
    end

    private
    private_constant :EXP, :EXP_APP_BASE_NAME, :LOCK_KEY, :LOCKED, :UNLOCKED

    def heroku(cmd, remote)
      Bundler.with_clean_env do
        `heroku #{cmd} -r #{remote}`
      end
    end

    def get_config(key, remote)
      heroku("config:get #{key}", remote)
    end

    def set_config(key, value, remote)
      heroku("config:set #{key}=#{value}", remote)
    end
  end
end
