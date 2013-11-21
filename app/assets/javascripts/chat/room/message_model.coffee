@Chat ?= {}
Chat.Room ?= {}

Chat.Room.Message = Backbone.Model.extend
  initialize: ->
    @set 'time_id', moment(@get 'at').format 'HH:mm'

Chat.Room.TalkMessageView = Backbone.View.extend
  tagName  : 'article'
  className: 'talk'

  attributes:
    time_class: ''
    user_class: ''

  template: _.template """
    <section class="time">
      <span class="<%= time_class %>"><%= time_id %></span>
    </section>
    <section class="user">
      <span class="<%= user_class %>"><%= user %></span>
    </section>
    <section class="message"><%= message %></section>
  """

  render: -> @_render()

  _render: (attrs = {}) ->
    @$el.html @template _({}).extend @model.attributes, @attributes, attrs
    @$el.find('.time').text('') unless @model.get('time_needed')
    @$el.find('.user').text('') unless @model.get('user_needed')
    if @model.get('highlight')
      @$el.removeClass('lighter').addClass('darker')
    else
      @$el.addClass('lighter').removeClass('darker')
    @

Chat.Room.JoinMessageView = Chat.Room.TalkMessageView.extend
  className: 'action joined'

  render: -> @_render message: 'joined this room'

Chat.Room.LeftMessageView = Chat.Room.TalkMessageView.extend
  className: 'action left'

  render: -> @_render message: 'left this room'

Chat.Room.ErrorMessageView = Chat.Room.TalkMessageView.extend
  className: 'error'

  template: _.template """
    <section class="time"></section>
    <section class="user"></section>
    <section class="message">
      <div class="alert alert-warning"><%= message %></div>
    </section>
  """