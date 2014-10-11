require "json"

class ReleaseManager < Sinatra::Application
  get "/" do
    erb :index
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read
    p payload["changes"][0]["original_values"]
    p payload["changes"][0]["new_values"]
  end
end
