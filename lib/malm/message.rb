module Malm
  class Message
    attr_reader :state, :email_body, :mail_from, :rcpt_to

    def initialize
      @email_body = ""
      @rcpt_to = []
      @state = :init_state
    end
  
    def process_line(line=nil)    
      if line =~ /QUIT/
        return quit!
      end
      
      # state machine pattern. Delegate to state handler for where we're at in SMTP conversation
      response = send(@state, line)
      return error! unless response
      
      # transition if state handler returned a new state
      new_state = response.delete(:state)
      @state = new_state if new_state
      
      response
    end
  
    def subject
      if @email_body =~ /^Subject\: (.+)$/
        $1.strip
      end
    end
  
    private
    def init_state(_ignore_line=nil)
      {:output => "220 hello\r\n", :state => :helo_state}
    end
    
    def helo_state(line)
      if (line =~ /^(HELO|EHLO)/)
        ok!(:mail_state)
      end
    end
    
    def mail_state(line)
      if (line =~ /^MAIL FROM\:<(.+)>.*$/)
        @mail_from = $1
        ok!(:rcpt_state)
      end
    end
    
    def rcpt_state(line)
      if (line =~ /^RCPT TO\:<(.+)>.*$/)
        @rcpt_to << $1
        ok!
      elsif (line =~ /^DATA/)
        {:output => "354 Enter message, ending with \".\" on a line by itself\r\n", :state => :data_state}
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
end