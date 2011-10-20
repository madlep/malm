# based on copy + paste from http://snippets.dzone.com/posts/show/5152
require 'gserver'

class Malm
  class SMTPServer < GServer
  
    attr_accessor :mail_log
    attr_accessor :message_db
    
    def serve(io)
      message = Message.new
      io.print message.process_line[:output]
      loop do
        data = io.gets
        response = message.process_line(data)
        io.print response[:output] if response[:output]
        break if response[:done]
        break if io.closed?
      end
      begin
        io.close
        db_insert(message)
      rescue => e
        log "something screwed up..."
        log e.backtrace
      end
    end
  
    def db_insert(message)
      subject_regex = /^Subject\: (.+)$/

      subject_match = subject_regex.match(message.email_body)
      subject = subject_match ? subject_match[1] : ""
      subject.strip!
    
      message_data = {:subject => subject, :from => message.mail_from, :to => message.rcpt_to, :body => message.email_body}
    
      @mail_log_fd.puts(message_data.inspect) if @mail_log_fd
      @message_db.create(message_data) if @message_db
    end
  
    protected
    def starting
      @mail_log_fd = File.open(@mail_log, "a") if @mail_log
      super
    end
  
    def stopping
      @mail_log_fd.close if @mail_log_fd
      super
    end
  
  end
end