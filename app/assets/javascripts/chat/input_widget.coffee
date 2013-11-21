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

  get_form: => @el.children('form').first()

  get_input_field: => @get_form().children('input').first()

  bind_events: =>
    @get_form().submit (e) =>
      e.preventDefault()
      @callbacks.message? @get_input_field().val()
      @get_input_field().val ''