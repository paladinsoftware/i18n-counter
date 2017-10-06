module I18n
  module Counter
    class Summary

      attr :redis, :used, :unused
      def initialize
        @redis = I18nRedis.connection
        @_redis_keys = {}
        @used = []
        @unused = []
        @_count_by_locale = {}
        @_sum_by_locale = {}
      end

      module RedisCounts
        def accessed_keys locale
          @_redis_keys[locale] ||= redis.keys("#{locale}.*")
        end

        def accessed_keys_global
          I18n.available_locales.each do |locale|
            locale_prefix = "#{locale}."
            accessed_keys(locale).each do |lkey|
              key = lkey.sub(locale_prefix, '')
              accessed_keys('global') << key unless accessed_key?('global', key)
            end
          end
          accessed_keys('global')
        end

        def accessed_key? locale, key
          accessed_keys(locale).index(key) == 0
        end

        def count_by_locale locale
          @_count_by_locale[locale] ||= accessed_keys(locale).size
        end

        def list_counts_by_locale
          I18n.available_locales.each.reduce({}) do |result, locale|
            result[locale] = count_by_locale(locale)
            result
          end
        end

        def count_all
          accessed_keys_global.size
        end

        def sum_all
          I18n.available_locales.each.reduce(0) { |sum, locale| sum += sum_by_locale(locale) }
        end

        def sum_by_locale locale
          @_sum_by_locale[locale] ||= accessed_keys(locale).reduce(0) {|sum, key| sum += redis.get(key).to_i }
        end
      end

      include RedisCounts

      module AvailableKeys
        def translation_used?(k)
          I18n.available_locales.detect do |locale|
            accessed_keys(locale).index("#{locale}.#{k}") == 0
          end
        end

        def available_keys locale
          local_locale(locale).select_keys do |k,v|
            yield k
          end
        end

        def local_locale locale
          load_locales.data[locale]
        end

        def load_locales
          @_locales ||= I18n::Tasks::BaseTask.new
        end
      end

      include AvailableKeys

      def call
        available_keys(DEFAULT_LOCALE) do |k|
          if translation_used?(k)
            @used << k.sub(DEFAULT_LOCALE, '')
          else
            @unused << k.sub(DEFAULT_LOCALE, '')
          end
        end
        self
      end
    end
  end
end
