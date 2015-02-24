class FriendsApp::Navigation extends Backbone.View

  initialize: ->
    @_throttled_onAll = _(@_updateStats).throttle 150, leading: false
    super

  render: ->
    @listenTo @collection, 'all', @_throttled_onAll  # NOTE the event callback params are ignored
    @_throttled_onAll()
    @


  _updateStats: ->
    @$el.
      animate(opacity: 0.1, 'slow').
      queue((next)=>
        @$el.html I18n.t('title_html', count: @collection.size(), scope: 'friends.navigation')
        next()
        ).
      animate(opacity: 1, 'slow')
