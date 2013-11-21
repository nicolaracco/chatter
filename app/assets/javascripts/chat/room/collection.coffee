@Chat ?= {}
Chat.Room ?= {}

class Chat.Room.Collection
  constructor: (@el) ->
    @el ?= $ '<div></div>'
    @collection = []

  add: (message) =>
    message.context =
      prev: =>
        index = @collection.indexOf(message)
        if index > 0 then @collection[index - 1] else null
    @collection.push message
    @el.append message.render()

  last: =>
    @collection[@collection.length - 1]

  refresh: =>
    @el.empty()
    for message in @collection
      @el.append message.render true