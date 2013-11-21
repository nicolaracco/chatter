@Chat ?= {}
Chat.Room ?= {}

Chat.Room.UserEntry = Backbone.Model.extend()

Chat.Room.UserEntryView = Backbone.View.extend
  tagName  : 'li'
  className: 'list-group-item'

  template: _.template """
    <span class="glyphicon glyphicon-user"></span>
    <%= name %>
  """

  render: ->
    @$el.html @template @model.attributes
    @$el.attr 'data-user-id', @model.get('name')
    @

Chat.Room.UserEntries = Backbone.Collection.extend
  model: (attrs, options) ->
    c = new Chat.Room.UserEntry name: attrs.user, options

Chat.Room.UserEntriesView = Backbone.View.extend
  className: 'users-list col-md-2'

  template: """<ul class="list-group"></ul>"""

  initialize: ->
    @listenTo @collection, 'add', @append_model
    @listenTo @collection, 'remove', @remove_model

  remove_model: (model) ->
    @$el.children('.list-group')
        .children("[data-user-id='#{model.get('name')}']")
        .remove()

  append_model: (model) ->
    view = new Chat.Room.UserEntryView {model}
    @$el.children('.list-group').append view.render().$el

  render: ->
    @$el.html @template
    @append_model model for model in @collection
    @