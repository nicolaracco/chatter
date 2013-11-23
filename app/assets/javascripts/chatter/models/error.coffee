@Chatter ?= {}

class Chatter.Error extends Backbone.Model

class Chatter.ErrorView extends Backbone.View
  className: 'alert alert-warning'

  template: _.template """
    <a class="close" data-dismiss="alert" href="#" aria-hidden="true">&times;</a>
    <p><%= description %>
  """

  render: =>
    @$el.html @template @attributes
    @