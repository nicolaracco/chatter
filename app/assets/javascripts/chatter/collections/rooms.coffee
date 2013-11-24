@Chatter ?= {}

class Chatter.Rooms extends Backbone.Collection
  model: (attrs, opts) =>
    new Chatter.Room attrs, opts

class Chatter.RoomsItemsView extends Backbone.View
  tagName: 'ul'
  className: 'nav nav-pills nav-stacked text-center'

  initialize: =>
    @listenTo @collection, 'add', @add_room_item
    @listenTo @collection, 'reset', @render

  add_room_item: (model) =>
    view = new Chatter.RoomItemView {model}
    view.on 'room-item:clicked', @room_item_clicked
    @$el.append view.render().$el

  render: =>
    @$el.empty()
    @collection.each @add_room_item
    @

  room_item_clicked: (room) =>
    @trigger 'room-item:clicked', room

  disable: =>
    @$el.find('a').attr 'disabled', 'disabled'

  enable: =>
    @$el.find('a').removeAttr 'disabled'