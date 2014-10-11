class ReleaseManager < Sinatra::Application
  get "/" do
    erb :index
  end

  post "/story" do
    story = params[:story]
    p story
  end
end
