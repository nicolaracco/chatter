@Chatter ?= {}

class Chatter.Error extends Backbone.Model
  initialize: =>
    @set 'active', false unless @get('active')?

class Chatter.ErrorView extends Backbone.View
  className: 'alert alert-warning hide'

  # <a class="close" data-dismiss="alert" href="#" aria-hidden="true">&times;</a>
  template: _.template """
    <p><%= description %>
  """

  initialize: =>
    super
    @listenTo @model, 'change', @render

  render: =>
    if @model.get('active')
      @$el.html @template @model.attributes
      @$el.removeClass 'hide'
    else
      @$el.empty()
      @$el.addClass 'hide'
    @