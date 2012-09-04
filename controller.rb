begin
  require 'bundler'
rescue LoadError
  require 'rubygems'
  require 'bundler'
end

Bundler.require

ignore /\.git/
ignore /\/_.*/
ignore /(Procfile|Gemfile|README*|config\.ru)/
layout 'layout.html.erb'