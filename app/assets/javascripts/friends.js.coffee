listView = null
$ ->
  listView = new window.FriendsApp.ListView collection: FriendsApp.friends
  new Navigation collection: FriendsApp.friends
  new Router
  Backbone.history.start()


class Router extends Backbone.Router
  routes:
    '': 'index'
    'search/:query': 'search'

  search: (query)->
    @_listView().select query

  index: ->
    @_listView()

  _listView: ->
    @__listView ||= listView.render()


class Navigation extends Backbone.View
  el: '#window-title'

  initialize: ->
    _(=> @render()).defer()
    super

  render: ->
    @$el.html I18n.t('title_html', count: @collection.size(), scope: 'friends.navigation')
    @
