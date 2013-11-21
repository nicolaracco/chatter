#= require jquery-2.0.3
#= require bootstrap
#= require chat/room_chooser
#= require chat/room_view
#= require chat/client

$ ->
  new Chat.Client() if $('#chat').length > 0