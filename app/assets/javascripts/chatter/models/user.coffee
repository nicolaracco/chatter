@Chatter ?= {}

class Chatter.User extends Backbone.Model
  parse: (data, options) ->
    { id: data.user, name: data.user }

class Chatter.UserView extends Backbone.View
  tagName  : 'li'
  className: 'list-group-item'

  template : _.template """
    <span class="glyphicon glyphicon-user"></span>
    <%= name %>
  """

  render: =>
    @$el.html @template @model.attributes
    @