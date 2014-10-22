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
    @source_project_id = 319467
    @target_project_id = 1185380
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read

    if payload["changes"][0]["new_values"]["current_state"] == "accepted"
      status = @conn.post "/services/v5/projects/#{@target_project_id}/stories", story_details(payload)
    end
  end

  def story_details p
    story_details = {
      name: p["primary_resources"][0]["name"],
      description: p["primary_resources"][0]["url"],
      story_type: p["primary_resources"][0]["story_type"],
      current_state: "finished",
      labels: get_labels(p["primary_resources"][0]["id"])
    }

    story_details[:estimate] = 0 if story_details[:story_type] == "feature"

    JSON.generate story_details
  end

  def get_labels story_id
    labels = JSON.parse( @conn.get("/services/v5/projects/#{@source_project_id}/stories/#{story_id}").body )["labels"]
    extract_label_names labels
  end

  def extract_label_names label_objects
    label_objects.each_with_object([]) do | o, labels |
      labels << {"name" => o["name"] }
    end
  end
end
