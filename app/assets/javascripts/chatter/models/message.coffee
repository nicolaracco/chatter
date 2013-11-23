@Chatter ?= {}

class Chatter.Message extends Backbone.Model

class Chatter.MessageView extends Backbone.View
  tagName  : 'article'
  className: 'log-entry'
  template : _.template """
    <section class="timestamp"><%= time %></section>
    <section class="user"><%= username %></section>
    <section class="message"><%= message %></section>
  """

  initialize: =>
    super
    @listenTo @model, 'change:message', @render

  render: =>
    @$el.html @template @converted_attributes()
    @$el.addClass "type-#{@model.get 'type'}"
    @

  converted_attributes: =>
    {
      time     : moment(@model.get('at')).format('HH:mm')
      username : @model.get('user')
      message  : @parse_description()
    }

  parse_description: =>
    message = @model.get('message')
    while message.indexOf("\n") > -1
      message = message.replace "\n", "<br/>"
    message