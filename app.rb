#!/usr/bin/env ruby
# conding: utf-8
require "sinatra"
require "slim"
require "slim/include"
require "sass"
require "coffee-script"
require "uri"
require "httparty"

configure do
  # You must be set to environmental variables
  unless ENV["GITHUB_APP_ID"] or ENV["GITHUB_APP_SECRET"]
    raise "set GITHUB_APP_ID and GITHUB_APP_SECRET"
  end

  # disable SSL verify
  HTTParty::Basement.default_options.update(verify: false)

  # store session to cookie
  use Rack::Session::Cookie, :key => 'rack.session',
   :expire_after => 2592000, # In seconds
   :secret => (ENV["GITHUB_APP_ID"] * 3 + ENV["GITHUB_APP_SECRET"] * 2).crypt("saltsalt")

  Slim::Engine.options[:pretty] = false
   
end

get '/' do
  unless session[:token]
    slim :authorize
  else
    @token = session[:token]
    # slim :repositories
    slim :commit_test
  end
end




get '/unauth' do
  session.clear
  redirect to '/'
end

get '/auth' do
  query = {
    client_id: ENV["GITHUB_APP_ID"],
    scope: 'repo',
    redirect_uri: "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/auth.callback",
  }.map{|k,v|
    "#{k}=#{URI.encode v}"
  }.join("&")
  redirect "https://github.com/login/oauth/authorize?#{query}"
end

get '/auth.callback' do
  code = params["code"]
  halt 400, "bad request (code)" if code.to_s.empty?

  ## get oauth token
  query = {
    body: {
      client_id: ENV["GITHUB_APP_ID"],
      client_secret: ENV["GITHUB_APP_SECRET"],
      code: code
    },
    headers: {
      "Accept" => "application/json"
    }
  }

  res = HTTParty.post("https://github.com/login/oauth/access_token", query)
  halt 500, "github auth error" unless res.code == 200
  begin
    token = JSON.parse(res.body)["access_token"]  ## tokenを取得！
    session[:token] = token
    redirect to '/'
  rescue
    halt 500, "github auth error"
  end
end
