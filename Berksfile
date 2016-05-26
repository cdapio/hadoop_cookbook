source 'https://supermarket.chef.io'

group :integration do
  cookbook 'java', '~> 1.21'
end

# This is here until bmhatfield/chef-ulimit#41 is merged and a new version of the cookbook is released
cookbook 'ulimit', github: 'wolf31o2/ulimit_cookbook', ref: 'feature/matchers'

# Restrict version due to Chef 12 requirement
if RUBY_VERSION.to_f < 2.0
  # cookbook 'mingw', '< 1.0'
  cookbook 'build-essential', '< 3.0'
  cookbook 'ohai', '< 4.0'
end

metadata
