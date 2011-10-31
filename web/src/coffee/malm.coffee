@Malm = {}

@Malm.start = () ->
    messageList = new MessageList()
    messageRouter = new MessageRouter()
    messageListView = new MessageListView("messageRouter": messageRouter, "collection": messageList)
    messageBodyView = new MessageBodyView()
    
    messageController = new MessageController(
      "messageList"     : messageList
      "messageListView" : messageListView
      "messageBodyView" : messageBodyView
    )
    messageRouter.messageController = messageController
    messageListView.messageController = messageController
    
    messageList.fetch("success": () -> Backbone.history.start())

class Message extends Backbone.Model


class MessageList extends Backbone.Collection
  model: Message
  url: "/messages"

  comparator: (message) ->
    message.id * -1


class MessageListView extends Backbone.View
  el: '#messagesContent'
  
  events:
    'click .reload a' : 'reload'
  
  initialize: () ->
    @messageRouter = @options.messageRouter
    @collection.bind('reset', @resetMessages)
    
  resetMessages: (messages) =>
    messages.each (message) =>
      view = new MessageView("model": message, "messageRouter": @messageRouter)
      $(@el).append(view.el)
        
  reload: () ->
    $(".messagesItem").remove()
    @messageController.reload()


class MessageView extends Backbone.View
  tagName: 'div'
  className: 'messagesItem'
  
  events:
    'click .contentTypeLinks a' : 'showMessage'
    
  initialize: () ->
    @template = $('#messageViewTemplate').html()
    @messageRouter = @options.messageRouter
    @render()
    
  render: () ->
    html = Mustache.to_html(@template, 
      "subject": @model.get("subject"),
      "htmlUrl": @model.get("body_urls").html,
      "textUrl": @model.get("body_urls").text
    )
    $(@el).append(html)
    
  showMessage: (e) ->
    contentType = e.target.className
    @messageRouter.navigate("/messages/#{@model.id}/body.#{contentType}", true)


class MessageBodyView extends Backbone.View
  el: "#messageBody"
  
  initialize: () ->
    @template = $('#messageBodyTemplate').html()
    @contentType = @options.contentType
    
  render: () ->
    html = Mustache.to_html(@template, "bodyUrl": @model.get("body_urls")[@contentType])
    $(@el).html(html)

class MessageController
  constructor: (options) -> 
    @messageList = options.messageList
  
  showMessage: (messageId, contentType) ->
    message = @messageList.get(messageId)
    bodyView = new MessageBodyView("model":message, "contentType": contentType)
    bodyView.render()
    
  reload: () ->
    @messageList.reset()
    @messageList.fetch()


class MessageRouter extends Backbone.Router
  routes: {
    '/messages/:id/body.:contentType' : 'showMesage'
  }
          
  showMesage: (messageId, contentType) ->
    @messageController.showMessage(messageId, contentType)
