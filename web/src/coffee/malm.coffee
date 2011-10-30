_.templateSettings = { interpolate : /\{\{(.+?)\}\}/g };

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
    
    messageList.fetch("add": true)
    
    Backbone.history.start()

class Message extends Backbone.Model


class MessageList extends Backbone.Collection
  model: Message
  url: "/messages"


class MessageListView extends Backbone.View
  el: '#messagesContent'
  
  initialize: () ->
    @messageRouter = @options.messageRouter
    @collection.bind('add', @renderItem)
    
  renderItem: (message) =>
    console.log(message.id)
    view = new MessageView("model": message, "messageRouter": @messageRouter)
    $(@el).append(view.el)


class MessageView extends Backbone.View
  tagName: 'div'
  className: 'messagesItem'
  
  events:
    'click a' : 'showMessage'
    
  initialize: () ->
    @template = _.template($('#messageViewTemplate').html())
    @messageRouter = @options.messageRouter
    @render()
    
  render: () ->
    html = @template("message": @model.toJSON())
    $(@el).append(html)
    
  showMessage: () ->
    @messageRouter.navigate("/messages/#{@model.id}", true)


class MessageBodyView extends Backbone.View
  el: "#messageBody"
  
  initialize: () ->
    @template = _.template($('#messageBodyTemplate').html())
    
  render: () ->
    html = @template("message": @model.toJSON())
    $(@el).html(html)

class MessageController
  constructor: (options) -> 
    @messageList = options.messageList
  
  showMessage: (messageId, term) ->
    message = @messageList.get(messageId)
    bodyView = new MessageBodyView("model":message)
    bodyView.render()


class MessageRouter extends Backbone.Router
  routes: {
    '/messages/:id' : 'showMesage'
  }
          
  showMesage: (messageId, type) ->
    @messageController.showMessage(messageId, type)
