@Chat ?= {}

class Chat.InputWidget
  callbacks: {}

  constructor: ->
    @el = $('#input-navbar')
    @bind_events()

  hide: => @el.addClass 'hide'

  show: =>
    @el.removeClass 'hide'
    @get_input_field().focus()

  on_message: (callback) => @callbacks.message = callback

  get_input_field: => @el.children('input').first()

  bind_events: =>
    @get_input_field().keyup (e) =>
      if e.keyCode is 13
        e.preventDefault()
        @callbacks.message? @get_input_field().val()
        @get_input_field().val ''