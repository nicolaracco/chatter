@Chatter ?= {}

class Chatter.Room extends Backbone.Model

class Chatter.RoomItemView extends Backbone.View
  tagName: 'li'
  className: 'room'

  template: _.template """
    <a href="#<%= id %>"><%= name %></a>
  """

  events:
    'click a' : 'click'

  render: =>
    @$el.html @template @model.attributes
    @

  click: (e) =>
    e.preventDefault()
    @trigger 'room-item:clicked', @model unless $(e.target).attr('disabled')