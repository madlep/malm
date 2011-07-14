require 'thin'
require 'sinatra/base'
require 'json'

class MalmWeb < Sinatra::Base
  get "/" do
    "Hello World\n"
  end
  
  get "/messages" do
    content_type :json
    settings.message_db.find_all.to_json
  end
  
  get "/messages/:id" do
    content_type :json
    id = Integer(params[:id])
    settings.message_db.find(id).to_json
  end
end