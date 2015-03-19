require "sinatra"
require "slim"
require "sass"
require "coffee-script"
require "uri"
require "httparty"

# ENV["GITHUB_APP_ID"] =
# ENV["GITHUB_APP_SECRET"] =

HTTParty::Basement.default_options.update(verify: false)

get '/auth' do
  query = {
    :client_id => ENV["GITHUB_APP_ID"],
    :redirect_uri => "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/auth.callback",
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
    :body => {
      :client_id => ENV["GITHUB_APP_ID"],
      :client_secret => ENV["GITHUB_APP_SECRET"],
      :code => code
    },
    :headers => {
      "Accept" => "application/json"
    }
  }

  res = HTTParty.post("https://github.com/login/oauth/access_token", query)
  puts res
  halt 500, "github auth error" unless res.code == 200
  begin
    @token = JSON.parse(res.body)["access_token"]  ## tokenを取得！
  rescue
    halt 500, "github auth error"
  end

  slim :github
end