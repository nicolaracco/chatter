@Chatter ?= {}

class Chatter.Messages extends Backbone.Collection
  model: (attrs, options) ->
    new Chatter.Message attrs, options

class Chatter.MessagesView extends Backbone.View
  attributes:
    scroll_locked: false

  initialize: =>
    @listenTo @collection, 'add',   (model) =>
      @add_message(model)
      _.defer @scroll_to_bottom
    @listenTo @collection, 'reset', @render

  delegateEvents: =>
    super
    @$el.parent().scroll =>
      @attributes.scroll_locked = @$el.parent().scrollTop() > @$el.height() - @$el.parent().height() - 10

  undelegateEvents: =>
    super
    $(@$el).unbind 'scroll'

  add_message: (model) =>
    view = new Chatter.MessageView {model}
    @$el.append view.render().$el

  add_error: (error) =>
    view = new Chatter.ErrorView model: error
    @$el.append view.render().$el

  render: =>
    @$el.empty()
    @collection.each @add_message
    _.defer @scroll_to_bottom
    @

  scroll_to_bottom: =>
    @$el.parent().scrollTop @$el.height() - @$el.parent().scrollTop() if @attributes.scroll_locked