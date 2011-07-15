require 'thin'
require 'sinatra/base'
require 'json'
require 'v8'
require 'execjs'
require 'coffee_script'
require 'mail'

class MalmWeb < Sinatra::Base
  
  set :public, File.join(File.dirname(__FILE__), "static")
  set :views, File.join(File.dirname(__FILE__), "views")
  
  get "/messages.json" do
    content_type :json
    settings.message_db.find_all.to_json
  end
  
  get "/messages/:id.json" do
    content_type :json
    find_message(params[:id]).to_json
  end
  
  get "/messages/:id/body.:type" do
    render_message(params[:id], params[:type])
  end
    
  get "/coffee/:script.coffee" do
    content_type "text/javascript"
    coffee params[:script].to_sym
  end
  
  private
  def find_message(id)
    id = Integer(id)
    settings.message_db.find(id)
  end
  
  def render_message(id, type)
    content_type type
    
    supported = ["text", "html"]
    unless supported.include?(type.to_s)
      halt 415, "don't know how to display message #{id} as #{type}. Try one of #{supported.join(",")}"
      return
    end
    
    msg_obj = find_message(id)
    if msg_obj
      Mail::Message.new(msg_obj[:body]).send("#{type}_part".to_sym).body.to_s
    else
      status 404
      "don't know about message #{id}"
    end
  end
end