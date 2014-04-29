module Sagan
  class Heroku
    def reset_db(remote)
      app_name = remote.gsub('exp', 'schoolkeep-experimental-')
      `heroku pg:reset DATABASE -r #{remote} --confirm #{app_name} && heroku run rake db:migrate db:seed -r #{remote} && heroku restart -r #{remote}`
    end

    def get_config(key, remote)
      `heroku config:get #{key} -r #{remote}`
    end

    def set_config(key, value, remote)
      `heroku config:set #{key}=#{value} -r #{remote}`
    end

    def maintenance_on(remote)
      `heroku maintenance:on -r #{remote}`
    end

    def maintenance_off(remote)
      `heroku maintenance:off -r #{remote}`
    end
  end
end
