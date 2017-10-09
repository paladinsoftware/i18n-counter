module I18n
  module Counter
    class Summary
      DEFAULT_LOCALE = 'en'

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
            accessed_keys(locale).each do |k|
              key =  strip_locale_from_key locale, k
              accessed_keys('global') << "global.#{key}" unless accessed_key?('global', key)
            end
          end
          accessed_keys('global')
        end

        def accessed_key? locale, key
          k = add_locale_to_key(locale, key)
          accessed_keys(locale).include?(k)
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

      module NativeKeys
        def translation_used?(k)
          I18n.available_locales.detect do |locale|
            accessed_key?(locale, "#{locale}.#{k}")
          end
        end
DEFAULT_LOCALE
        def native_keys locale = DEFAULT_LOCALE
          local_locale(locale).select_keys do |k,v|
            yield k
          end
        end

        def list_native_keys locale = DEFAULT_LOCALE
          keys = []
          native_keys(locale) { |k| keys << k}
          keys
        end

        def local_locale locale
          load_locales.data[locale]
        end

        def load_locales
          @_locales ||= I18n::Tasks::BaseTask.new
        end
      end

      include NativeKeys

      def call locale = DEFAULT_LOCALE
        native_keys(locale) do |k|
          key = strip_locale_from_key locale, k
          if translation_used?(key)
            @used << key
          else
            @unused << key
          end
        end
        self
      end

      private
      def strip_locale_from_key locale, key
        key.sub("#{locale}.", '')
      end

      def add_locale_to_key locale, key
        key =~ /^#{locale}\.*/ ? key : "#{locale}.#{key}"
      end
    end
  end
end
