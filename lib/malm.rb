require 'malm/message_db'
require 'malm/smtp_server'
require 'malm/web'

class Malm
  attr_accessor :log, :smtpport, :webport
  
  def initialize(options={})
    options.each{|k,v| send("#{k}=", v)}
  end
  
  def run!
    create_db
    run_smtp!
    run_web!
  end
  
  private
  def create_db
    @db = Malm::MessageDb.new
  end

  def run_smtp!
    smtp_server = Malm::SMTPServer.new(@smtpport)
    smtp_server.mail_log = @log
    smtp_server.message_db = @db

    begin
      smtp_server.start
    rescue Errno::EACCES
      STDERR.puts("Don't have permission to start SMTP server on port #{smtpport}. Maybe run with sudo?")
      exit 1
    end
    smtp_server
  end

  def run_web!
    Malm::Web.set :port, @webport
    Malm::Web.set :message_db, @db
    Malm::Web.run!
  end
end