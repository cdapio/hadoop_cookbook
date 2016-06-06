source 'https://supermarket.chef.io'

group :integration do
  cookbook 'java', '~> 1.21'
  cookbook 'ulimit', '>= 0.4.0'
end

# Restrict version due to Chef 12 requirement
if RUBY_VERSION.to_f < 2.0
  cookbook 'apt', '< 4.0'
  cookbook 'build-essential', '< 3.0'
  cookbook 'ohai', '< 4.0'
end

metadata
