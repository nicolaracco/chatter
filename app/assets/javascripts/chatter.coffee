#= require jquery-2.0.3
#= require underscore
#= require bootstrap
#= require moment-with-langs
#= require chat/client

$ ->
  new Chat.Client() if $('#chat').length > 0