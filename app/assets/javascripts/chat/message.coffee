@Chat ?= {}

templates =
  message: """
    <p class="<%= type %>">
      <span class="time"><%= time_id %></span>
      <span class="user"><%= username %></span>
      <span class="message"><%= message %></span>
    </p>
  """
class Chat.Message
  constructor: (data) ->
    @at       = new Date data.at
    @type     = data.type ? 'message'
    @username = data.user
    @message  = switch @type
      when 'joined' then 'joined this room'
      when 'left'   then 'left this room'
      else data.message

    @day_id      = moment(@at).format 'YYYYMMDD'
    @date_header = moment(@at).format("dddd, MMMM Do YYYY")
    @time_id     = moment(@at).format 'HH:mm'

    @create_element()

  create_element: =>
    @el = $ _(templates.message).template
      type    : @type
      time_id : @time_id
      username: @username
      message : @message

  style_respect_to_previous: (previous) =>
    if previous.time_id is @time_id and previous.username is @username
      @el.addClass previous.el.hasClass('darken') and 'lighten' or 'darken'
    else
      @el.addClass previous.el.hasClass('darken') and 'darken' or 'lighten'

    if previous.time_id is @time_id
      @el.find('.time').text('')
      if @type is previous.type and previous.username is @username
        @el.find('.user').text('')