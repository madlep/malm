require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Malm::SMTPServer do
  before do
    @db = mock("db")
    @io = mock("io")
  end
  
  describe "SMTP conversation" do
    it "should receive a message" do
      @io.should_receive(:closed?).at_least(:once).and_return(false)
      
      @io.should_receive(:gets).and_return(
        "HELO smtp.example.com\r\n", 
        "MAIL FROM:<from@example.com>\r\n",
        "RCPT TO:<receiver1@example.com>\r\n",
        "RCPT TO:<receiver2@example.com>\r\n",
        "DATA\r\n",
        "Subject: This is a test\r\n",
        "This is a line\r\n",
        "This is another line\r\n",
        ".\r\n",
        "QUIT\r\n"
      )
      
      @io.should_receive(:print).with("220 hello\r\n").ordered
      @io.should_receive(:print).with("250 OK\r\n").exactly(5).times.ordered
      @io.should_receive(:print).with("354 Enter message, ending with \".\" on a line by itself\r\n").ordered
      @io.should_receive(:print).with("221 bye\r\n").ordered
      @io.should_receive(:close).ordered
      
      @db.should_receive(:create).with(
        :subject  => "This is a test", 
        :from     => "from@example.com", 
        :to       => ["receiver1@example.com", "receiver2@example.com"], 
        :body     => "Subject: This is a test\r\nThis is a line\r\nThis is another line\r\n")
      
      smtp_server = Malm::SMTPServer.new(2525)
      smtp_server.message_db = @db
      
      smtp_server.serve(@io)
    end
  end
end
