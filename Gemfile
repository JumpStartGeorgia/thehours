source 'https://rubygems.org'

gem 'bundler'
gem "rails", "3.2.18"
gem "mysql2", "~> 0.3.16" # this gem works better with utf-8

gem "json"
gem "jquery-rails", '~> 3.1.0' #"~> 1.0.19" 
gem "devise", "~> 2.0.4" # user authentication
gem 'omniauth' # to login via facebook
gem 'omniauth-facebook' # to login via facebook
gem "cancan", "~> 1.6.8" # user authorization
gem "formtastic", "~> 2.2.1" # create forms easier
gem "formtastic-bootstrap", :git => "https://github.com/mjbellantoni/formtastic-bootstrap.git", :branch => "bootstrap3_and_rails4"
gem 'tinymce-rails', "~> 3.5.8", :branch => "tinymce-3" #tinymce editor https://github.com/spohlenz/tinymce-rails/tree/tinymce-4
#gem "nested_form", "~> 0.1.1", :git => "https://github.com/davidray/nested_form.git" # easily build nested model forms with ajax links
gem 'globalize', '~> 3.1.0' # internationalization
gem 'psych', '~> 2.0.5' # yaml parser - default psych in rails has issues
gem 'gon', '~> 5.0.4' # push data into js
gem "dynamic_form", "~> 1.1.4" # to see form error messages
gem "i18n-js", "~> 2.1.2" # to show translations in javascript
gem "capistrano", "~> 2.12.0" # to deploy to server
gem "exception_notification", "~> 2.5.2" # send an email when exception occurs
gem "useragent", :git => "https://github.com/jilion/useragent.git" # browser detection
#gem "rails_autolink", "~> 1.0.9" # convert string to link if it is url
#gem 'paperclip', '~> 3.4.0' # to upload files
#gem "has_permalink", "~> 0.1.4" # create permalink slugs for nice urls
gem "will_paginate", "~> 3.0.5" # add paging to long lists
#gem "kaminari", "~> 0.15.1" # paging

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
  gem "therubyracer"
  gem 'less-rails', git: 'git://github.com/metaskills/less-rails.git'
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'  , branch: 'bootstrap3'
  gem 'jquery-datatables-rails', '~> 3.3.0'
  gem "jquery-ui-rails" , "~> 4.1.2"  
end


group :development do
 	gem "mailcatcher", "0.5.12" # small smtp server for dev, http://mailcatcher.me/
  gem 'rb-inotify', '~> 0.8.8' # rails dev boost needs this
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git' # speed up loading page in dev mode
end

group :staging, :production do
  gem 'unicorn', '~> 4.8.3' # http server
end

