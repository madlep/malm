class Messages extends Backbone.Collection
  initialize: () ->
    @url = "/messages"
    
  comparator: (message) ->
    messages.id * -1
    
  
    
this.Messages = Messages