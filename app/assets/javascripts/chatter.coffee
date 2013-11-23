#= require chatter/connection

$ ->
  Chatter.connection.connect()

  pages = new Chatter.Pages
  home_page = pages.add id: 'home', name: 'Home'

  pages_links_view = new Chatter.PagesLinksView
    collection: pages
    el        : $('#pages-links')
  pages_view = new Chatter.PagesView
    collection: pages
    el        : $('#pages')
  pages_links_view.render()
  pages_view.render()

  home_page.on 'create-room:success', (room) ->
    existing_page = pages.findWhere id: room.id
    if existing_page?
      existing_page.set 'active', true
    else
      pages.add room
  home_page.on 'join-room', (room) ->
    existing_page = pages.findWhere id: room.attributes.id
    if existing_page?
      existing_page.set 'active', true
    else
      pages.add room.attributes