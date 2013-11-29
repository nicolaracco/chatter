@Chatter ?= {}

class Chatter.User extends Backbone.Model
  parse: (data, options) ->
    { id: data.user, name: data.user }

  destroy: =>
    @trigger 'destroy'

class Chatter.UserView extends Backbone.View
  tagName  : 'li'
  className: 'list-group-item'

  template : _.template """
    <span class="glyphicon glyphicon-user"></span>
    <%= name %>
  """

  initialize: =>
    super
    @listenTo @model, 'destroy', @remove

  render: =>
    @$el.html @template @model.attributes
    @