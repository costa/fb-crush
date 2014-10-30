listView = null
$ ->
  listView = new window.FriendsApp.ListView collection: window.FriendsApp.friends
  new Router
  Backbone.history.start()


class Router extends Backbone.Router
  routes:
    '': 'index'

  index: ->
    @_listView()

  _listView: ->
    @__listView ||= listView.render()
