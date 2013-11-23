@Chatter ?= {}

class Chatter.Pages extends Backbone.Collection
  initialize: =>
    @on 'add', @set_last_as_active
    @on 'destroy', (model) =>
      @remove model
      @set_last_as_active()
    @on 'change:active', (model) =>
      if model.get('active') and @where(active: true).length > 1
        @each (other) ->
          other.set 'active', false if other.id isnt model.id

  set_last_as_active: =>
    @each (model) =>
      model.set 'active', model.id is @last().id

  model: (attrs, options) ->
    if attrs.id is 'home'
      new Chatter.HomePage attrs, options
    else
      new Chatter.RoomPage attrs, options

class Chatter.PagesLinksView extends Backbone.View
  tagName  : 'ul'
  className: 'nav navbar-nav navbar'

  initialize: =>
    @listenTo @collection, 'add', @add_page_link

  add_page_link: (model) =>
    view = new Chatter.PageLinkView {model}
    @$el.append view.render().$el

  render: =>
    @$el.empty()
    @collection.each @add_page_link
    @

class Chatter.PagesView extends Backbone.View
  className: 'container'

  initialize: =>
    @listenTo @collection, 'add', @add_page

  render: =>
    @$el.empty()
    @collection.each @add_page

  add_page: (model) =>
    view = if model.id is 'home'
      new Chatter.HomePageView {model}
    else
      new Chatter.RoomPageView {model}
    @$el.append view.render().$el