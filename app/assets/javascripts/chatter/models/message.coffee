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

  render: =>
    @$el.html @template @converted_attributes()
    @$el.addClass "type-#{@model.get 'type'}"
    @

  converted_attributes: =>
    {
      time     : moment(@model.get('at')).format('HH:mm')
      username : @model.get('user')
      message  : @model.get('message')
    }