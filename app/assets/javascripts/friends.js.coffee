listView = null

window.FriendsApp ||= {}
FriendsApp.run = ->
  listView = new FriendsApp.ListView collection: FriendsApp.friends
  new Navigation collection: FriendsApp.friends
  new Router
  Backbone.history.start()


class Router extends Backbone.Router
  routes:
    '': 'index'

  index: ->
    @_listView()

  _listView: ->
    @__listView ||= listView.render()


class Navigation extends Backbone.View
  el: '#window-title'

  initialize: ->
    super
    @_throttledRender = _(@render).throttle(333)
    @listenTo @collection, 'all', @_throttledRender  # NOTE the event callback params are ignored
    @_throttledRender()

  render: ->
    @$el.
      animate(opacity: 0.1, 'slow').
      queue((next)=>
        @$el.html I18n.t('title_html', count: @collection.size(), scope: 'friends.navigation')
        next()
        ).
      animate(opacity: 1, 'slow')
    @
