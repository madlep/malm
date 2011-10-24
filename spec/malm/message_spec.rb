require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Malm::Message do
  before(:each) do
    @message = Malm::Message.new
  end
  
  describe "#process_line" do
    describe "in INIT state" do
      it "responds with hello" do
        @message.process_line(:any_old_input)[:output].should == "220 hello\r\n"
      end
      
      it "should transition to HELO state on any input" do
        @message.process_line(nil)
        @message.state.should == :helo_state        
      end
    end
    
    describe "in HELO state" do
      before(:each) do
        @message.process_line(nil) # transition to HELO state
      end  
      
      describe "input 'HELO'" do
        it "should be OK" do
          @message.process_line("HELO")[:output].should == "250 OK\r\n"
        end
        it "should transition to MAIL state" do
          @message.process_line("HELO")
          @message.state.should == :mail_state
        end
      end
      
      describe "input 'EHLO'" do
        it "should be OK" do
          @message.process_line("EHLO")[:output].should == "250 OK\r\n"
        end
        it "should transition to MAIL state" do
          @message.process_line("EHLO")
          @message.state.should == :mail_state
        end
      end    
    end 
    
    describe "in MAIL state" do
      before(:each) do
        @message.process_line(nil) # transition to HELO state
        @message.process_line("HELO\r\n") # transition to MAIL state
      end
      
      describe "input MAIL FROM <...>" do
        before(:each) do
          @reponse = @message.process_line("MAIL FROM:<francis@example.com>\r\n")
        end
        
        it "should be OK" do
          @reponse[:output].should == "250 OK\r\n"
        end
        
        it "should transition to RCPT state" do
          @message.state.should == :rcpt_state
        end
        
        it "should set the from address" do
          @message.mail_from.should == "francis@example.com"
        end
      end
    end
    
    describe "in RCPT state" do
      before(:each) do
        @message.process_line(nil) # transition to HELO state
        @message.process_line("HELO\r\n") # transition to MAIL state
        @message.process_line("MAIL FROM:<francis@example.com>\r\n") # transition to RCPT state        
      end
      
      describe "input RCPT TO:<...>" do
        before(:each) do
          @reponse = @message.process_line("RCPT TO:<louis@example.com>\r\n")
        end
        
        it "adds the recipient" do
          @message.rcpt_to.should == ["louis@example.com"]
        end
        
        it "does not transition state" do
          @message.state.should == :rcpt_state
        end
        
        it "should be OK" do
          @reponse[:output].should == "250 OK\r\n"
        end

      end
      
      describe "input DATA" do
        before(:each) do
          @reponse = @message.process_line("DATA\r\n")
        end
        
        it "should be 354 response" do
          @reponse[:output].should == "354 Enter message, ending with \".\" on a line by itself\r\n"
        end
        
        it "should transition to DATA state" do
          @message.state.should == :data_state
        end
      end
    end 
    
    describe "in DATA state" do
      before(:each) do
        @message.process_line(nil) # transition to HELO state
        @message.process_line("HELO\r\n") # transition to MAIL state
        @message.process_line("MAIL FROM:<francis@example.com>\r\n") # transition to RCPT state
        @message.process_line("RCPT TO:<louis@example.com>\r\n") # transition to DATA state
        @message.process_line("DATA\r\n") # transition to DATA state
      end
      
      it "accumulates data" do
        @message.process_line("line 1\r\n")
        @message.process_line("line 2\r\n")
        @message.process_line("line 3\r\n")
        @message.email_body.should == "line 1\r\nline 2\r\nline 3\r\n"
      end
      
      describe "input ." do
        before(:each) do
          @message.process_line("line 1\r\n")
          @response = @message.process_line(".\r\n")
        end
        
        it "should be OK" do
          @response[:output].should == "250 OK\r\n"
        end
        
        it "should transition to QUIT state" do
          @message.state.should == :quit_state
        end
        
      end
    end       
  end
  
  describe "#subject" do
    it "should be extracted from email body" do
      @message.process_line(nil) # transition to HELO state
      @message.process_line("HELO\r\n") # transition to MAIL state
      @message.process_line("MAIL FROM:<francis@example.com>\r\n") # transition to RCPT state
      @message.process_line("RCPT TO:<louis@example.com>\r\n") # transition to DATA state
      @message.process_line("DATA\r\n") # transition to DATA state

      @message.process_line("Subject: This is a subject\r\n")
      @message.process_line("This is NOT a subject\r\n")      
      
      @message.subject.should == "This is a subject"
    end
  end
end