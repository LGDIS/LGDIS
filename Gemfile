source 'http://rubygems.org'

gem 'rails', '3.2.11'
gem "jquery-rails", "2.2.0"
gem "i18n", "0.6.1"
gem "coderay", "1.0.8"
# 1.9 or later system, you do not need to be installed
# gem "fastercsv", "~> 1.5.0", :platforms => [:mri_18, :mingw_18, :jruby]
gem "builder", "3.0.0"
gem 'debugger'

# Optional gem for LDAP authentication
group :ldap do
  gem "net-ldap", "0.3.1"
end

# Optional gem for OpenID authentication
group :openid do
  gem "ruby-openid", "2.2.2", :require => "openid"
  gem "rack-openid", "1.3.1"
end

# Optional gem for exporting the gantt to a PNG file, not supported with jruby
platforms :mri, :mingw do
  group :rmagick do
    # RMagick 2 supports ruby 1.9
    # RMagick 1 would be fine for ruby 1.8 but Bundler does not support
    # different requirements for the same gem on different platforms
    gem "rmagick", "2.13.1"
  end
end

# Database gems
platforms :mri, :mingw do
  group :postgresql do
    gem "pg", "0.14.1"
  end

  group :sqlite do
    gem "sqlite3", "1.3.7"
  end
end

platforms :mri_18, :mingw_18 do
  group :mysql do
    gem "mysql", "2.9.0"
  end
end

platforms :mri_19, :mingw_19 do
  group :mysql do
    gem "mysql2", "0.3.11"
  end
end

platforms :jruby do
  gem "jruby-openssl", "0.8.2"

  group :mysql do
    gem "activerecord-jdbcmysql-adapter", "1.2.5"
  end

  group :postgresql do
    gem "activerecord-jdbcpostgresql-adapter", "1.2.5"
  end

  group :sqlite do
    gem "activerecord-jdbcsqlite3-adapter", "1.2.5"
  end
end

group :development do
  gem "rdoc", "3.12"
  gem "yard", "0.8.3"
end

group :test do
  gem "shoulda", "2.11.3"
  # Shoulda does not work nice on Ruby 1.9.3 and JRuby 1.7.
  # It seems to need test-unit explicitely.
  platforms = [:mri_19]
  platforms << :jruby if defined?(JRUBY_VERSION) && JRUBY_VERSION >= "1.7"
  gem "test-unit", "2.5.3", :platforms => platforms
  gem "mocha", "0.13.1"
end

group :development, :test do
  gem 'rspec', '2.12.0'
  gem 'rspec-rails', '2.12.2'
  gem 'factory_girl_rails', '4.2.0'
end

local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exists?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end

# Load plugins' Gemfiles
Dir.glob File.expand_path("../plugins/*/Gemfile", __FILE__) do |file|
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end
