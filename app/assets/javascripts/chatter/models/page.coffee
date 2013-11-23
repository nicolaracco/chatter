@Chatter ?= {}

class Chatter.Page extends Backbone.Model
  initialize: =>
    @set 'active', false unless @get('active')?

  is_removable: -> false

class Chatter.PageLinkView extends Backbone.View
  tagName: 'li'
  template: _.template """
    <a href="#<%= id %>">
      <%= icon %>
      <%= name %>
      <%= close_button %>
    </a>
  """
  icon_template: _.template """
    <span class="glyphicon glyphicon-<%= icon %>"></span>
  """
  close_template: """
    <button type="button" class="close close-tab" aria-hidde="true">&times;</button>
  """

  events:
    'click a'      : 'activate'
    'click .close' : 'destroy'

  initialize: =>
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove

  render: =>
    @$el.html @template _(@model.attributes).extend
      icon        : if @icon()? then @icon_template(icon: @icon()) else ''
      close_button: if @model.is_removable() then @close_template else ''
    if @model.get 'active'
      @$el.addClass 'active'
    else
      @$el.removeClass 'active'
    @

  icon: =>
    switch @model.constructor.name
      when 'HomePage' then 'home'
      when 'RoomPage' then 'bullhorn'
      else null

  activate: (e) =>
    e.preventDefault()
    @model.set 'active', true

  destroy: (e) =>
    e.preventDefault()
    @model.destroy()

class Chatter.PageView extends Backbone.View
  className: 'page'

  initialize: =>
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove

  render: =>
    @$el.attr 'id', @model.id
    if @model.get 'active'
      @$el.addClass 'active'
    else
      @$el.removeClass 'active'