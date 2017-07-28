source 'https://rubygems.org'

gem 'berkshelf', '~> 3.0'

gem 'chefspec', '~> 4.0'
gem 'rspec', '~> 3.0'

# rubocop: disable Lint/UnneededDisable
# rubocop: disable Bundler/DuplicatedGem

if RUBY_VERSION.to_f < 2.0
  gem 'buff-ignore', '< 1.2'
  gem 'chef', '< 12.0'
  gem 'chef-zero', '< 4.6'
  gem 'dep_selector', '< 1.0.4'
  gem 'fauxhai', '< 3.5'
  gem 'ffi-yajl', '< 2.3'
  gem 'foodcritic', '~> 4.0'
  gem 'json', '< 2.0'
  gem 'mixlib-shellout', '< 2.3.0'
  gem 'net-http-persistent', '< 3.0'
  gem 'nio4r', '< 2.0'
  gem 'nokogiri', '< 1.7'
  gem 'rack', '< 2.0'
  gem 'rubocop', '< 0.42'
  gem 'varia_model', '< 0.5.0'
elsif RUBY_VERSION.to_f == 2.0
  gem 'buff-ignore', '< 1.2'
  gem 'chef', '< 12.5'
  gem 'chef-zero', '< 4.6'
  gem 'dep_selector', '< 1.0.4'
  gem 'fauxhai', '< 3.5'
  gem 'ffi-yajl', '< 2.3'
  gem 'foodcritic', '~> 6.0'
  gem 'mixlib-shellout', '< 2.3.0'
  gem 'net-http-persistent', '< 3.0'
  gem 'nio4r', '< 2.0'
  gem 'nokogiri', '< 1.7'
  gem 'rack', '< 2.0'
  gem 'rubocop'
elsif RUBY_VERSION.to_f == 2.1
  gem 'chef', '< 12.5'
  gem 'fauxhai', '< 3.10'
  gem 'ffi-yajl', '< 2.3.1'
  gem 'foodcritic', '~> 6.0'
  gem 'mixlib-shellout', '< 2.3.0'
  gem 'nio4r', '< 2.0'
  gem 'rack', '< 2.0'
  gem 'rubocop'
elsif RUBY_VERSION.to_f == 2.2
  gem 'chef', '< 12.5'
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop'
elsif RUBY_VERSION.to_f == 2.3
  gem 'chef', '< 12.5'
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop'
else
  gem 'chef'
  gem 'foodcritic'
  gem 'rubocop'
end

gem 'dep-selector-libgecode', '< 1.3.1'
gem 'faraday', '< 0.9.2'
gem 'rainbow', '<= 1.99.1'
gem 'ridley', '~> 4.2.0'

group :integration do
  gem 'kitchen-vagrant'
  gem 'test-kitchen'
end
