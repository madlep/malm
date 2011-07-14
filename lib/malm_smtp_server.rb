# based on copy + paste from http://snippets.dzone.com/posts/show/5152
require 'gserver'

class MalmSMTPServer < GServer
  
  attr_accessor :mail_log
  attr_accessor :message_db
  
  class Session
    attr_accessor :data_mode, :data_mode, :email_body, :mail_from, :rcpt_to, :subject
    alias :data_mode? :data_mode
    
    def initialize
      @data_mode = false
      @email_body = ""
    end
        
  end
  
  def serve(io)
    session = Session.new
    puts "Connected"
    io.print "220 hello\r\n"
    loop do
      if IO.select([io], nil, nil, 0.1)
        data = io.readpartial(4096)
        puts ">>" + data
        ok, op = process_line(data, session)
        break unless ok
        puts "<<" + op
        io.print op
      end
      break if io.closed?
    end
    db_insert(session)
    io.print "221 bye\r\n"
    io.close
  end

  def process_line(line, session)
    if (session.data_mode?) && (line.chomp =~ /^\.$/)
      session.data_mode = false
      return true, "250 OK\r\n"
    elsif session.data_mode?
      session.email_body += line
      return true, ""
    elsif (line =~ /^(HELO|EHLO)/)
      return true, "250 and..?\r\n"
    elsif (line =~ /^QUIT/)
      return false, "bye\r\n"
    elsif (line =~ /^MAIL FROM\:/)
      session.mail_from = (/^MAIL FROM\:<(.+)>.*$/).match(line)[1]
      return true, "250 OK\r\n"
    elsif (line =~ /^RCPT TO\:/)
      session.rcpt_to = (/^RCPT TO\:<(.+)>.*$/).match(line)[1]
      return true, "250 OK\r\n"
    elsif (line =~ /^DATA/)
      session.data_mode = true
      return true, "354 Enter message, ending with \".\" on a line by itself\r\n"
    else
      return true, "500 ERROR\r\n"
    end
  end
  
  def db_insert(session)
    subject_regex = /^Subject\: (.+)$/

    subject = subject_regex.match(session.email_body)[1] || ""
    subject.strip!
    
    message = {:subject => subject, :from => session.mail_from, :to => session.rcpt_to, :body => session.email_body}
    
    @mail_log_fd.puts(message.inspect) if @mail_log_fd
    @message_db.create(message) if @message_db
    
    log("Message received: #{message.inspect}")
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