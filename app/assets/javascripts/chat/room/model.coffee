@Chat ?= {}
Chat.Room ?= {}

class Chat.Room.Model
  constructor: (@attributes) ->

  get: (attribute) => @attributes[attribute]

  set: (attributes) =>
    for key, value of attributes
      @attributes[key] = value

  render: (force_refresh = false) =>
    if force_refresh && @el?
      @el.replaceWith @create_el_tag()
    else
      @el = null if force_refresh
      @el ?= @create_el_tag()

  create_el_tag: -> $ '<div></div>'