require "json"

class ReleaseManager < Sinatra::Application
  before do
    request.body.rewind
    @request_payload = JSON.parse request.body.read
  end

  get "/" do
    erb :index
  end

  post "/story" do
    p @request_payload
  end
end
