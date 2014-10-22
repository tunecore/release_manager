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
p payload
      status = @conn.post "/services/v5/projects/1185380/stories", story_details(payload)
    end
  end

  def story_details p
    story_details = {
      name: p["primary_resources"][0]["name"],
      description: p["primary_resources"][0]["url"],
      story_type: p["primary_resources"][0]["story_type"],
      current_state: "finished",
      labels: []
    }

    p["changes"][0]["new_values"]["labels"].each{ | label | story_details[:labels] << {"name" => label} }

    story_details[:estimate] = 0 if story_details[:story_type] == "feature"

    JSON.generate story_details
  end
end
