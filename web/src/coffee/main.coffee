this.malm_init = (messages_content_element) ->
  messages = new Messages()
  messages_view = new MessagesView(collection: messages, el: messages_content_element)
  messages.fetch()
