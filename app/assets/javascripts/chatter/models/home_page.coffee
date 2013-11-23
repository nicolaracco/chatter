@Chatter ?= {}

class Chatter.HomePage extends Chatter.Page
  constructor: ->
    @rooms = new Chatter.Rooms
    super

  initialize: =>
    super
    do (conn = Chatter.connection) =>
      conn.on 'home:rooms', @reset
      conn.on 'home:error', (data) =>
        @trigger 'error', new Chatter.Error data
      conn.on 'home:create-room:error', (data) =>
        @trigger 'create-room:error', new Chatter.Error data
      conn.on 'home:create-room:success', (data) =>
        @trigger 'create-room:success', data
      conn.on 'home:rooms:created', (data) =>
        @rooms.add data
      conn.emit 'home:rooms'

  reset: (data) =>
    @rooms.reset data.rooms

  create_room: (name) =>
    Chatter.connection.emit 'home:create-room', name

  join_room: (room) =>
    @trigger 'join-room', room

class Chatter.CreateRoomModalView extends Backbone.View
  tagName: 'modal fade'

  template: """
    <div class="modal-dialog"><div class="modal-content">
      <div class="modal-header">
        <button class="close" type="button" data-dismiss="modal" aria-hidden="true"> &times;</button>
        <h4 class="modal-title">Create Room</h4>
      </div>
      <form role="form">
        <div class="modal-body"><div class="form-group">
          <label>Name</label>
          <input class="form-control" type="text" placeholder="Foo Bar Baz" name="name" required="true" />
        </div></div>
        <div class="modal-footer">
          <button class="btn btn-default" type="button" data-dismiss="modal">Close</button>
          <button class="btn btn-primary" type="submit">Save changes</button>
        </div>
      </form>
    </div></div>
  """

  events:
    'submit form' : 'trigger_submit'

  show_error: (error) =>
    view = new Chatter.ErrorView model: error
    @$el.find('.modal-body').prepend view.render().$el

  render: =>
    @$el.attr 'role', 'dialog'
    @$el.attr 'aria-labelledby', 'Create Room'
    @$el.attr 'aria-hidden', 'true'
    @$el.html @template
    @

  show: =>
    @name_field().val ''
    @$el.modal 'show'
    setTimeout =>
      @name_field().focus()
    , 500

  hide: =>
    @$el.modal 'hide'
    @remove_alerts()

  remove_alerts: =>
    @$el.find('.alert').remove()

  name_field: =>
    @$el.find 'input[name="name"]'

  trigger_submit: (e) =>
    e.preventDefault()
    @remove_alerts()
    @trigger 'form-submit', @name_field().val()

class Chatter.HomePageView extends Chatter.PageView
  template: """
    <div class="row">
      <ul class="nav nav-pills nav-stacked text-center">
      </ul>
      <div class="actions text-center">
        <button type="button" class="btn btn-default btn-lg open-create-room">Create Room</button>
      </div>
      <div class="modal fade"></div>
    </div>
  """

  events:
    'click .open-create-room' : 'open_create_room_modal'

  initialize: =>
    super
    @modal_view = new Chatter.CreateRoomModalView
    @rooms_view = new Chatter.RoomsItemsView
      collection: @model.rooms

    @listenTo @model, 'error', @show_error
    @listenTo @model, 'create-room:error', @modal_view.show_error
    @listenTo @model, 'create-room:success', @modal_view.hide
    @modal_view.on 'form-submit', @create_room
    @rooms_view.on 'room-item:clicked', @join_room

  show_error: (error) =>
    view = new Chatter.ErrorView model: error
    @$el.prepend view.render().$el

  render: =>
    @$el.html @template
    @rooms_view.setElement(@nav_el()).render()
    @modal_view.setElement(@modal_el()).render()
    super
    @

  content_el: =>
    @$el.children('.row')

  nav_el: =>
    @content_el().children('ul.nav')

  modal_el: =>
    @$el.find('.modal')

  open_create_room_modal: =>
    @modal_view.show()

  create_room: (name) =>
    @model.create_room name

  join_room: (room) =>
    @model.join_room room

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
    @trigger 'room-item:clicked', @model

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