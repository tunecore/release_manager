require "json"
require "faraday"
require "pp"

class ReleaseManager < Sinatra::Application
  configure do
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  before do
    @conn = Faraday.new(:url => "https://www.pivotaltracker.com") do | faraday |
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    @conn.headers = {"Content-Type" => "application/json", "X-TrackerToken" => ENV["TRACKER_API_KEY"]}
  end

  post "/copy_to_qa" do
    request.body.rewind
    payload = JSON.parse request.body.read
    target_project_id = 1543967

    if payload["highlight"] == "accepted"
      res = @conn.post "/services/v5/projects/#{target_project_id}/stories", story_details(payload)
      logger.info res.status
    end
  end

  post "/story" do
    request.body.rewind
    payload = JSON.parse request.body.read
    target_project_id = 1185380

    if payload["highlight"] == "accepted"
      res = @conn.post "/services/v5/projects/#{target_project_id}/stories", story_details(payload)
      logger.info res.status
    end
  end

  def process_story project_id
    request.body.rewind
    payload = JSON.parse request.body.read

    if payload["highlight"] == "accepted"
      res = @conn.post "/services/v5/projects/#{project_id}/stories", story_details(payload)
      logger.info res.status
    end
  end

  def story_details p
    story_details = {
      name: p["primary_resources"][0]["name"],
      description: p["primary_resources"][0]["url"],
      story_type: p["primary_resources"][0]["story_type"],
      current_state: "finished",
      labels: get_labels(p["primary_resources"][0]["id"], p["project"]["id"])
    }

    story_details[:estimate] = 0 if story_details[:story_type] == "feature"

    JSON.generate story_details
  end

  def get_labels story_id, project_id
    labels = JSON.parse( @conn.get("/services/v5/projects/#{project_id}/stories/#{story_id}").body )["labels"]
    extract_label_names labels
  end

  def extract_label_names label_objects
    label_objects.each_with_object([]) do | o, labels |
      labels << {"name" => o["name"] }
    end
  end
end
