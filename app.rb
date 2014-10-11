require "json"
require "faraday"

class ReleaseManager < Sinatra::Application
  before do
    @conn = Faraday.new(:url => "https://www.pivotaltracker.com") do | faraday |
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
      status = @conn.post "/services/v5/projects/1185380/stories", story_details(payload)
      p status
    end
  end

  def story_details p
    JSON.generate(
    { name: p["primary_resources"][0]["name"],
      description: p["primary_resources"][0]["url"],
      story_type: p["primary_resources"][0]["story_type"],
      current_state: "delivered",
      estimate: 0
    })
  end
end
