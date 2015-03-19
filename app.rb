require "sinatra"
require "sass"
require "haml"
require "coffee-script"

get '/' do
  redirect to '/index.html'
end
