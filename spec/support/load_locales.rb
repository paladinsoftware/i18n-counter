Dir[File.join(I18n::Tasks.gem_path, 'spec/support/config', 'locales', '*.yml')].each do |locale_file|
  I18n.config.load_path << locale_file
end
