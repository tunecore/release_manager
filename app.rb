require "json"

class ReleaseManager < Sinatra::Application
  get "/" do
    erb :index
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read
    p request["changes"]["original_values"]
    p request["changes"]["new_values"]
  end
end
