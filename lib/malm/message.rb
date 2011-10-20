class Message
  attr_accessor :data_mode, :data_mode, :email_body, :mail_from, :rcpt_to, :subject

  def initialize
    @data_mode = false
    @email_body = ""
    @rcpt_to = []
  end
  
  def process_line(line)
    if (@data_mode) && (line.chomp =~ /^\.$/)
      @data_mode = false
      return true, "250 OK\r\n"
    elsif @data_mode
      @email_body += line
      return true, ""
    elsif (line =~ /^(HELO|EHLO)/)
      return true, "250 and..?\r\n"
    elsif (line =~ /^QUIT/)
      return false, "221 bye\r\n"
    elsif (line =~ /^MAIL FROM\:/)
      @mail_from = (/^MAIL FROM\:<(.+)>.*$/).match(line)[1]
      return true, "250 OK\r\n"
    elsif (line =~ /^RCPT TO\:/)
      @rcpt_to << (/^RCPT TO\:<(.+)>.*$/).match(line)[1]
      return true, "250 OK\r\n"
    elsif (line =~ /^DATA/)
      @data_mode = true
      return true, "354 Enter message, ending with \".\" on a line by itself\r\n"
    else
      return true, "500 ERROR\r\n"
    end
  end
    
end
