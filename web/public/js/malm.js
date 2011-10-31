(function() {
  var Message, MessageBodyView, MessageController, MessageList, MessageListView, MessageRouter, MessageView;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  this.Malm = {};
  this.Malm.start = function() {
    var messageBodyView, messageController, messageList, messageListView, messageRouter;
    messageList = new MessageList();
    messageRouter = new MessageRouter();
    messageListView = new MessageListView({
      "messageRouter": messageRouter,
      "collection": messageList
    });
    messageBodyView = new MessageBodyView();
    messageController = new MessageController({
      "messageList": messageList,
      "messageListView": messageListView,
      "messageBodyView": messageBodyView
    });
    messageRouter.messageController = messageController;
    messageListView.messageController = messageController;
    return messageList.fetch({
      "success": function() {
        return Backbone.history.start();
      }
    });
  };
  Message = (function() {
    __extends(Message, Backbone.Model);
    function Message() {
      Message.__super__.constructor.apply(this, arguments);
    }
    return Message;
  })();
  MessageList = (function() {
    __extends(MessageList, Backbone.Collection);
    function MessageList() {
      MessageList.__super__.constructor.apply(this, arguments);
    }
    MessageList.prototype.model = Message;
    MessageList.prototype.url = "/messages";
    MessageList.prototype.comparator = function(message) {
      return message.id * -1;
    };
    return MessageList;
  })();
  MessageListView = (function() {
    __extends(MessageListView, Backbone.View);
    function MessageListView() {
      this.resetMessages = __bind(this.resetMessages, this);
      MessageListView.__super__.constructor.apply(this, arguments);
    }
    MessageListView.prototype.el = '#messagesContent';
    MessageListView.prototype.events = {
      'click .reload a': 'reload'
    };
    MessageListView.prototype.initialize = function() {
      this.messageRouter = this.options.messageRouter;
      return this.collection.bind('reset', this.resetMessages);
    };
    MessageListView.prototype.resetMessages = function(messages) {
      return messages.each(__bind(function(message) {
        var view;
        view = new MessageView({
          "model": message,
          "messageRouter": this.messageRouter
        });
        return $(this.el).append(view.el);
      }, this));
    };
    MessageListView.prototype.reload = function() {
      $(".messagesItem").remove();
      return this.messageController.reload();
    };
    return MessageListView;
  })();
  MessageView = (function() {
    __extends(MessageView, Backbone.View);
    function MessageView() {
      MessageView.__super__.constructor.apply(this, arguments);
    }
    MessageView.prototype.tagName = 'div';
    MessageView.prototype.className = 'messagesItem';
    MessageView.prototype.events = {
      'click .contentTypeLinks a': 'showMessage'
    };
    MessageView.prototype.initialize = function() {
      this.template = $('#messageViewTemplate').html();
      this.messageRouter = this.options.messageRouter;
      return this.render();
    };
    MessageView.prototype.render = function() {
      var html;
      html = Mustache.to_html(this.template, {
        "subject": this.model.get("subject"),
        "htmlUrl": this.model.get("body_urls").html,
        "textUrl": this.model.get("body_urls").text
      });
      return $(this.el).append(html);
    };
    MessageView.prototype.showMessage = function(e) {
      var contentType;
      contentType = e.target.className;
      return this.messageRouter.navigate("/messages/" + this.model.id + "/body." + contentType, true);
    };
    return MessageView;
  })();
  MessageBodyView = (function() {
    __extends(MessageBodyView, Backbone.View);
    function MessageBodyView() {
      MessageBodyView.__super__.constructor.apply(this, arguments);
    }
    MessageBodyView.prototype.el = "#messageBody";
    MessageBodyView.prototype.initialize = function() {
      this.template = $('#messageBodyTemplate').html();
      return this.contentType = this.options.contentType;
    };
    MessageBodyView.prototype.render = function() {
      var html;
      html = Mustache.to_html(this.template, {
        "bodyUrl": this.model.get("body_urls")[this.contentType]
      });
      return $(this.el).html(html);
    };
    return MessageBodyView;
  })();
  MessageController = (function() {
    function MessageController(options) {
      this.messageList = options.messageList;
    }
    MessageController.prototype.showMessage = function(messageId, contentType) {
      var bodyView, message;
      message = this.messageList.get(messageId);
      bodyView = new MessageBodyView({
        "model": message,
        "contentType": contentType
      });
      return bodyView.render();
    };
    MessageController.prototype.reload = function() {
      this.messageList.reset();
      return this.messageList.fetch();
    };
    return MessageController;
  })();
  MessageRouter = (function() {
    __extends(MessageRouter, Backbone.Router);
    function MessageRouter() {
      MessageRouter.__super__.constructor.apply(this, arguments);
    }
    MessageRouter.prototype.routes = {
      '/messages/:id/body.:contentType': 'showMesage'
    };
    MessageRouter.prototype.showMesage = function(messageId, contentType) {
      return this.messageController.showMessage(messageId, contentType);
    };
    return MessageRouter;
  })();
}).call(this);
