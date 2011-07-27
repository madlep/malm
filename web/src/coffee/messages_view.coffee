class MessagesView extends Backbone.View

  initialize: () ->
    @template = Handlebars.compile($("#messages_template").html())
    @collection.bind('all', @render)
    @render()
    
  render: () =>
    # Load the compiled HTML into the Backbone "el"
    content = @template("messages": @collection.toJSON())
    @el.html(content)
  
this.MessagesView = MessagesView