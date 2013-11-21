@Chat ?= {}
Chat.Room ?= {}

Chat.Room.DayGroup = Backbone.Model.extend
  initialize: ->
    @messages = new Chat.Room.Messages

Chat.Room.DayGroupView = Backbone.View.extend
  tagName: 'section'
  className: 'messages_of_day'
  template: _.template """
    <ol class="breadcrumb">
      <li class="active"><%= label %></li>
    </ol>
  """

  initialize: ->
    @messagesView = new Chat.Room.MessagesView collection: @model.messages

  render: ->
    @$el.html @template @model.attributes
    @$el.append @messagesView.render().$el
    @
