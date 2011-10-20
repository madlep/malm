# based on copy + paste from http://snippets.dzone.com/posts/show/5152
require 'gserver'

class Malm
  class SMTPServer < GServer
  
    attr_accessor :mail_log
    attr_accessor :message_db
  
    class Message
      attr_accessor :data_mode, :data_mode, :email_body, :mail_from, :rcpt_to, :subject
      alias :data_mode? :data_mode
    
      def initialize
        @data_mode = false
        @email_body = ""
        @rcpt_to = []
      end
        
    end
  
    def serve(io)
      message = Message.new
      log "Connected"
      io.print "220 hello\r\n"
      loop do
        data = io.gets
        log ">>" + data
        ok, op = process_line(data, message)
        log "<<" + op 
        io.print op               
        break unless ok
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

    def process_line(line, message)
      if (message.data_mode?) && (line.chomp =~ /^\.$/)
        message.data_mode = false
        return true, "250 OK\r\n"
      elsif message.data_mode?
        message.email_body += line
        return true, ""
      elsif (line =~ /^(HELO|EHLO)/)
        return true, "250 and..?\r\n"
      elsif (line =~ /^QUIT/)
        return false, "221 bye\r\n"
      elsif (line =~ /^MAIL FROM\:/)
        message.mail_from = (/^MAIL FROM\:<(.+)>.*$/).match(line)[1]
        return true, "250 OK\r\n"
      elsif (line =~ /^RCPT TO\:/)
        message.rcpt_to << (/^RCPT TO\:<(.+)>.*$/).match(line)[1]
        return true, "250 OK\r\n"
      elsif (line =~ /^DATA/)
        message.data_mode = true
        return true, "354 Enter message, ending with \".\" on a line by itself\r\n"
      else
        return true, "500 ERROR\r\n"
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
    
      log("Message received: #{message_data.inspect}")
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