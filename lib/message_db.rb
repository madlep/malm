require 'thread'

class MessageDb
  
  def initialize
    @sempahore = Mutex.new
    
    @message_db = []
  end
  
  def create(message)
    @sempahore.synchronize do
      @message_db << message
      @message_db.size
    end
  end
  
  def find_all
    @sempahore.synchronize do
      @message_db.dup
    end
  end

end