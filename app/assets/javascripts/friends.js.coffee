listView = null

window.FriendsApp ||= {}
FriendsApp.run = ->
  listView = new FriendsApp.ListView(collection: FriendsApp.friends).render()
  navigation = new Navigation(collection: FriendsApp.friends).render()


class Navigation extends Backbone.View
  el: '#window-title'

  initialize: ->
    @_throttled_onAll = _(@_onAll).throttle 150, leading: false
    super

  render: ->
    @listenTo @collection, 'all', @_throttled_onAll  # NOTE the event callback params are ignored
    @_throttled_onAll()
    @

  _onAll: ->
    @$el.
      animate(opacity: 0.1, 'slow').
      queue((next)=>
        @$el.html I18n.t('title_html', count: @collection.size(), scope: 'friends.navigation')
        next()
        ).
      animate(opacity: 1, 'slow')
