require "json"

class ReleaseManager < Sinatra::Application
  before do
    @conn = Faraday.new(:url => "https://www.pivotaltracker.com/services/v5/projects/1185380") do | faraday |
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read

    if payload["changes"][0]["new_values"]["current_state"] == "accepted"
      p payload

      @conn.post do | req |
        req.url "/stories"
        req.headers["Content-Type"] = "application/json"
        req.headers["X-TrackerToken"] = ENV["TRACKER_API_KEY"]
        req.body = '{"name": "Testing"}'
      end
    end
  end
end
