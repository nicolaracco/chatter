@Chat ?= {}
Chat.Room ?= {}

class Chat.Room.ErrorMessage extends Chat.Room.Message
  constructor: (attributes) ->
    super attributes
    @templates = _({}).extend @templates,
      user   : """
        <section class="user"></section>
      """
      message: """
        <section class="message">
          <div class="alert alert-warning">
            <%= message %>
          </div>
        </section>
      """

  create_el_tag: =>
    super highlight_mode: "#{@highlight_mode()} error"