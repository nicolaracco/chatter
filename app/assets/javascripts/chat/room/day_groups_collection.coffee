@Chat ?= {}
Chat.Room ?= {}

Chat.Room.DayGroups = Backbone.Collection.extend
  model: (attrs, options) ->
    id = moment(attrs.at).format 'YYYYMMDD'
    label = moment(attrs.at).format 'MMMM Do YYYY'
    new Chat.Room.DayGroup {id,label}

  id_from_raw_data: (data) ->
    moment(data.at).format 'YYYYMMDD'

Chat.Room.DayGroupsView = Backbone.View.extend
  className: 'room-output col-md-10'

  template: """<div class="wrapper"></div>"""

  initialize: ->
    @listenTo @collection, 'add', @append_model

  append_model: (model) ->
    view = new Chat.Room.DayGroupView {model}
    @$el.find('.wrapper').append view.render().$el

  render: ->
    @$el.html @template
    @append_model model for model in @collection
    @