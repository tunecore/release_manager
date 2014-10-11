require "json"
require "faraday"

class ReleaseManager < Sinatra::Application
  before do
    @conn = Faraday.new(:url => "https://www.pivotaltracker.com/services/v5/projects/1185380") do | faraday |
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    @conn.headers = {"Content-Type" => "application/json", "X-TrackerToken" => ENV["TRACKER_API_KEY"]}
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read

    if payload["changes"][0]["new_values"]["current_state"] == "accepted"
      p payload
      status = @conn.post "/stories", '{"name": "Testing"}'
      p status
    end
  end
end
