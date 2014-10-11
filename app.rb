require "json"

class ReleaseManager < Sinatra::Application
  get "/" do
    erb :index
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read

    if payload["changes"][0]["new_values"]["current_state"] == "accepted"
      p payload
    end
  end
end
