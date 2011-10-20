class Message
  attr_accessor :data_mode, :data_mode, :email_body, :mail_from, :rcpt_to, :subject
  alias :data_mode? :data_mode

  def initialize
    @data_mode = false
    @email_body = ""
    @rcpt_to = []
  end
    
end
