require 'i18n'
require "i18n/counter/version"

module I18n
  module Counter
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
        separator = options[:separator] || I18n.default_separator
        flat_key = I18n.normalize_keys(locale, key, scope, separator).join(separator)
        I18nRedis.connection.incr(flat_key)
        super
      end
    end
  end
  Backend::Simple.prepend(Counter::Hook)
end