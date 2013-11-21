@Chat ?= {}
Chat.Room ?= {}

Chat.Room.Messages = Backbone.Collection.extend
  model: (attrs, options) ->
    new Chat.Room.Message attrs, options

  initialize: ->
    @on 'add', @set_time_and_user_needed

  set_time_and_user_needed: (model) ->
    index = @indexOf model
    if index is 0
      time_needed = user_needed = true
      highlight = false
    else
      prev = @at index - 1
      if prev.get('type') is model.get('type')
        time_needed = prev.get('time_id') isnt model.get('time_id')
        user_needed = time_needed or prev.get('user') isnt model.get('user')
        highlight = if user_needed
          not prev.get('highlight')
        else
          prev.get('highlight')
      else
        time_needed = user_needed = true
        highlight = not prev.get('highlight')

    model.set 'time_needed', time_needed
    model.set 'user_needed', user_needed
    model.set 'highlight',   highlight

Chat.Room.MessagesView = Backbone.View.extend
  className: 'messages'

  initialize: ->
    @listenTo @collection, 'add', @append_model

  append_model: (model) ->
    Klass = @message_view_class(model.get 'type')
    view = new Klass {model}
    @$el.append view.render().$el

  render: ->
    @$el.empty()
    @append_model model for model in @collection
    @

  message_view_class: (type) ->
    ns = Chat.Room
    switch type
      when 'joined' then ns.JoinMessageView
      when 'left'   then ns.LeftMessageView
      when 'error'  then ns.ErrorMessageView
      else ns.TalkMessageView

