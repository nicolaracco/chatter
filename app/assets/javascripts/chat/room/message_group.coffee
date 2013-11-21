#= require model

@Chat ?= {}
Chat.Room ?= {}

class Chat.Room.MessageGroup extends Chat.Room.Model
  template: """
    <section class="messages_of_day">
      <ol class="breadcrumb">
        <li class="active"><%= label %></li>
      </ol>
    </section>
  """

  constructor: (message, context) ->
    attributes =
      collection: new Chat.Room.Collection $ '<div class="messages"></div>'
      id        : @id_from_message(message)
      label     : @label_from_message(message)
    super attributes, context

  message_can_stay: (message) =>
    @get('id') is @id_from_message(message)

  add: (message) =>
    @get('collection').add message

  create_el_tag: =>
    el = $ _(@template).template label: @get('label')
    el.append @get('collection').el
    el

  id_from_message: (message) -> moment(message.get 'at').format 'YYYYMMDD'

  label_from_message: (message) -> moment(message.get 'at').format('MMMM Do YYYY');