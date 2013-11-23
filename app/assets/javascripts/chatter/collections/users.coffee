@Chatter ?= {}

class Chatter.Users extends Backbone.Collection
  model: (attrs, options) -> new Chatter.User attrs, options

class Chatter.UsersView extends Backbone.View
  tagName  : 'ul'
  className: 'list-group users-list'

  initialize: ->
    @listenTo @collection, 'add', @add_user
    @listenTo @collection, 'reset', @render

  add_user: (model) =>
    view = new Chatter.UserView {model}
    @$el.append view.render().$el

  render: =>
    @$el.empty()
    @collection.each @add_user
    @