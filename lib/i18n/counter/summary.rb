module I18n
  module Counter
    class Summary
      GLOBAL_LOCALE = 'global'
      attr :redis, :used, :unused
      def initialize
        @redis = I18nRedis.connection
        @_redis_keys = {}
        @used = []
        @unused = []
        @_redis_keys = {}
      end

      def accessed_keys locale = GLOBAL_LOCALE
        @_redis_keys[locale] ||= redis.keys("#{locale}.*")
      end

      def accessed_key_count_by_locale
        I18n.available_locales.each.reduce({}) do |result, locale|
          result[locale] = redis.keys("#{locale}.*").size
          result
        end
      end

      def call
        I18n::Tasks::BaseTask.new.data[DEFAULT_LOCALE].select_keys do |k,v|
          if translation_used?(k)
            @used << k.sub(DEFAULT_LOCALE, '')
          else
            @unused << k.sub(DEFAULT_LOCALE, '')
          end
        end
        self
      end

      def translation_used?(k)
        I18n.available_locales.detect do |locale|
          accessed_keys(locale).index("#{locale}.#{k}") == 0
        end
      end
    end
  end
end
