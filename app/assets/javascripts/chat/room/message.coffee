#= require model

@Chat ?= {}
Chat.Room ?= {}

class Chat.Room.Message extends Chat.Room.Model
  templates:
    el: """
      <article class="<%= highlight_mode %>">
        <%= time %><%= user %><%= message %>
      </article>
    """
    time: """
      <section class="time"><%= time %></section>
    """
    user: """
      <section class="user"><%= username %></section>
    """
    message: """
      <section class="message"><%= message %></section>
    """

  constructor: (attributes) ->
    super attributes
    if @get('at')?
      @set timestamp: moment(@get 'at').format 'HH:mm'

  highlight_mode: =>
    @_highlight_mode ?= do =>
      prev = @context.prev()
      return 'lighter' unless prev?
      prev_mode = prev.highlight_mode()
      if @is_user_needed()
        if prev_mode is 'darker' then 'lighter' else 'darker'
      else
        prev_mode

  is_time_needed: =>
    @_is_time_needed ?= do =>
      return true unless @context.prev()?
      @get('timestamp') isnt @context.prev().get('timestamp')

  is_user_needed: =>
    @_is_user_needed ?= do =>
      return true unless @context.prev()?
      @get('username') isnt @context.prev().get('username') or @is_time_needed()

  create_message_tag: (attrs = {}) =>
    attrs = _(message: @get('message')).extend attrs
    _(@templates.message).template attrs

  create_user_tag: (attrs = {}) =>
    username = if @is_user_needed() then @get('username') else ''
    attrs = _({username}).extend attrs
    _(@templates.user).template attrs

  create_time_tag: (attrs = {}) =>
    time = if @is_time_needed() then @get('timestamp') else ''
    attrs = _({time}).extend attrs
    _(@templates.time).template attrs

  create_el_tag: (attrs = {}) =>
    message = @create_message_tag attrs
    user    = @create_user_tag attrs
    time    = @create_time_tag attrs
    highlight_mode = @highlight_mode()
    attrs = _({message,user,time,highlight_mode}).extend attrs
    $ _(@templates.el).template attrs