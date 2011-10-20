class Message
  attr_accessor :email_body, :mail_from, :rcpt_to

  def initialize
    @email_body = ""
    @rcpt_to = []
    @state = :hello_state
  end
  
  def process_line(line=nil)    
    response = (line =~ /^QUIT/) ? quit! : send(@state, line)
    @state = response.delete(:state) if response[:state]
    response
  end
  
  def subject
    subject_regex = /^Subject\: (.+)$/

    subject_match = subject_regex.match(@email_body)
    subj = subject_match ? subject_match[1] : ""
    subj.strip!
  end
  
  private
  def hello_state(_ignore)
    {:output => "220 hello\r\n", :state => :headers_state}
  end
  
  def headers_state(line)
    if (line =~ /^DATA/)
      return {:output => "354 Enter message, ending with \".\" on a line by itself\r\n", :state => :data_state}
    end
    
    if (line =~ /^(HELO|EHLO)/)
      ok!
    elsif (line =~ /^MAIL FROM\:/)
      @mail_from = (/^MAIL FROM\:<(.+)>.*$/).match(line)[1]
      ok!
    elsif (line =~ /^RCPT TO\:/)
      @rcpt_to << (/^RCPT TO\:<(.+)>.*$/).match(line)[1]
      ok!
    else
      error!
    end
  end
  
  def data_state(line)
    if (line.chomp =~ /^\.$/)
      ok!(:quit_state)
    else
      @email_body << line
      {}
    end
  end
  
  def quit_state(_ignore)
    error!
  end
  
  def quit!
    {:output => "221 bye\r\n", :state => :quit_state, :done => true}
  end
  
  def error!
    {:output => "500 ERROR\r\n", :state => :quit_state, :done => true}
  end
  
  def ok!(state=nil)
    {:output => "250 OK\r\n", :state => state}
  end
    
    
end
