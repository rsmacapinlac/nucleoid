require 'singleton'
require 'json'

module Mgwen
  class Config
    include Singleton
    CONFIGURATION_ITEMS = ["dnd", "NUCLEOID_NUMBER", "FORWARDING_NUMBER", "EMAIL", "APP_PUBLIC_HOST"]
    def initialize
      @configuration = { }
      for setting in Setting.all
        @configuration[setting.config_name] = setting.value
      end
    end

    def to_json
      @configuration.to_json
    end

    def get(k)
      return @configuration[k]
    end

    def get_or_set(k, v)
      val = @configuration[k]
      if val.nil? or val == ""
        set(k, v)
      end
    end

    def set(k, v)
      _s = Setting.find_by(config_name: k)
      @configuration[k] = v
      unless _s.nil?
        _s.value = v.to_s
        _s.save
      end
    end

    def self.setup
      for config in Mgwen::Config::Configuration_ITEMS
        self.register(config)
      end
    end

    def self.register(key)
      s = Setting.find_by(config_name: key)
      if s.nil?
        Setting.create(config_name: key).save
      end
    end

  end
end
