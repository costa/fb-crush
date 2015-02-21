class FriendsApp::ListView extends Backbone.View

  el: '#friends'

  initialize: ->
    super
    @_throttled_bound_onScroll = _(=> @_triggerScroll()).throttle 150, leading: false
    @_throttled_bound_onResize = _(=> @_triggerScroll true).throttle 900, leading: false

  render: ->

    addItemFor = (friend)=>
      view = new FriendsApp::ItemView(model: friend, dad: @).render()  # XXX some potential for optimisation here
      view.$el.appendTo @$el
      @kids[friend.id] = view
      @_throttled_bound_onResize()

    # NOTE preloaded collection handling (might be obsolete in the future)
    @kids = {}
    @collection.each addItemFor
    @listenTo @collection, 'add', addItemFor

    @listenTo @collection, 'remove', (friend)->
      @listenToOnce @kids[friend.id], 'remove:ready', ->
        @kids[friend.id].remove()
        @_throttled_bound_onResize()
        delete @kids[friend.id]
      @kids[friend.id].trigger 'remove'

    @listenTo @collection, 'sort', _(=>
      @collection.each (friend)=>
        @kids[friend.id].$el.appendTo @$el
    ).throttle(@collection.size() * 3)

    @_bindGlobal()

    @

  remove: ->
    @_unbindGlobal()
    @stopListening()

    _(@kids).each (v)-> v.remove()
    @

  _bindGlobal: ->
    $(document).on 'scroll', @_throttled_bound_onScroll
    $(window).on 'resize', @_throttled_bound_onResize

  _unbindGlobal: ->
    $(document).off 'scroll', @_throttled_bound_onScroll
    $(window).off 'resize', @_throttled_bound_onResize

  _triggerScroll: (resizing)->
    top = $(document).scrollTop()
    @trigger 'scroll', top, top + $(window).height(), resizing
