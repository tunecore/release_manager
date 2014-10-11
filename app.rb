require "json"

class ReleaseManager < Sinatra::Application
  get "/" do
    erb :index
  end

  post "/story" do
    request.body.rewind
    @request_payload = JSON.parse request.body.read
    p @request_payload
  end
end
