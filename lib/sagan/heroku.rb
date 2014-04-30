module Sagan
  class Heroku
    EXP = 'exp'
    EXP_APP_BASE_NAME = 'schoolkeep-experimental-'
    LOCK_KEY = 'EXPERIMENTAL_AVAILABLE'
    LOCKED = 'false'
    UNLOCKED = 'true'

    def lock(remote)
      set_config(LOCK_KEY, LOCKED, remote)
    end

    def unlock(remote)
      set_config(LOCK_KEY, UNLOCKED, remote)
    end

    def unlocked?(remote)
      get_config(LOCK_KEY, remote).to_s.start_with?("true")
    end

    def maintenance_off(remote)
      heroku("maintenance:off", remote)
    end

    def maintenance_on(remote)
      heroku("maintenance:on", remote)
    end

    def reset_db(remote)
      app_name = remote.gsub(EXP, EXP_APP_BASE_NAME)

      heroku("pg:reset DATABASE --confirm #{app_name}", remote)
      heroku("run rake db:migrate db:seed", remote)
      heroku("restart", remote)
    end

    private_constant :EXP, :EXP_APP_BASE_NAME, :LOCK_KEY, :LOCKED, :UNLOCKED
    private

    def heroku(cmd, remote)
      `heroku #{cmd} -r #{remote}`
    end

    def get_config(key, remote)
      heroku("config:get #{key}", remote)
    end

    def set_config(key, value, remote)
      heroku("config:set #{key}=#{value}", remote)
    end
  end
end
