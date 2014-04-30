module Sagan
  class Heroku
    EXP = 'exp'
    EXP_APP_BASE_NAME = 'schoolkeep-experimental-'

    def reset_db(remote)
      app_name = remote.gsub(EXP, EXP_APP_BASE_NAME)

      heroku("pg:reset DATABASE --confirm #{app_name}", remote)
      heroku("run rake db:migrate db:seed", remote)
      heroku("restart", remote)
    end

    def get_config(key, remote)
      heroku("config:get #{key}", remote)
    end

    def set_config(key, value, remote)
      heroku("config:set #{key}=#{value}", remote)
    end

    def maintenance_on(remote)
      heroku("maintenance:on", remote)
    end

    def maintenance_off(remote)
      heroku("maintenance:off", remote)
    end

    private_constant :EXP, :EXP_APP_BASE_NAME
    private

    def heroku(cmd, remote)
      `heroku #{cmd} -r #{remote}`
    end
  end
end
