require 'i18n'
require "i18n/counter/version"
require "i18n/counter/summary"

module I18n
  module Counter

    DEFAULT_LOCALE = 'en'
    GLOBAL_LOCALE = 'global'

    module I18nRedis
      class << self
        attr_accessor :redis
        def connection
          @redis ||= Redis.new url: determine_redis_provider
        end
        def determine_redis_provider
          ENV[ENV['I18N_REDIS_PROVIDER'] || ENV['REDIS_PROVIDER'] || 'REDIS_URL']
        end
      end
    end

    module Hook
      def lookup(locale, key, scope = [], options = {})
        return super unless ENV['ENABLE_I18N_COUNTER'] == 'true'
        separator = options[:separator] || I18n.default_separator
        global_scope = GLOBAL_LOCALE # to also count the translation key in general, disregarding the current locale scope
        [locale, global_scope].each do |l|
          flat_key = I18n.normalize_keys(l, key, scope, separator).join(separator)
          I18nRedis.connection.incr(flat_key)
        end
        super
      end
    end
  end
  Backend::Simple.prepend(Counter::Hook)
end
