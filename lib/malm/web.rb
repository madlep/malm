require 'thin'
require 'sinatra/base'
require 'json'
require 'mail'

class Malm
  class Web < Sinatra::Base
  
    set :public, File.join(File.dirname(__FILE__), "..", "..", "web", "public")
    set :views, File.join(File.dirname(__FILE__), "..", "..", "web", "views")
  
    get "/" do
      erb :'index.html'
    end
  
    get "/messages.json" do
      content_type :json
      settings.message_db.find_all.map{|m|
        m = m.dup
        m.delete(:body)
        m[:body_urls] = {:html => url("/messages/#{m[:id]}/body.html"), :text => url("/messages/#{m[:id]}/body.text")}
        m
      }.to_json
    end
  
    get "/messages/:id.json" do
      content_type :json
      find_message(params[:id]).to_json
    end
  
    get "/messages/:id/body.:type" do
      render_message(params[:id], params[:type])
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
end