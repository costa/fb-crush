class FriendsApp::ListView extends Backbone.View


  initialize: ->
    super
    @_throttled_bound_onScroll = _(=> @_triggerScroll()).throttle 150, leading: false
    @_throttled_bound_onResize = _(=> @_triggerScroll true).throttle 900, leading: false
    @_throttled_bound_onCollectionChange = _(=> @_addItUp()).throttle 30, leading: false
    @_throttled_bound_onFilter = _(=> @_dofilter()).throttle 150, leading: false
    @_changed_items = []

  render: ->
    # NOTE preloaded collection handling (might be obsolete in the future)
    @kids = {}

    @listenTo @collection, 'add change:prev_crush_friend_id change:next_crush_friend_id', @_addItem
    @collection.each @_addItem
    @listenTo @collection, 'remove', @_removeItem
    @on 'filter', (str)=> @_onFilter str

    @_bindGlobal()

    @

  remove: ->
    @_unbindGlobal()
    @stopListening()

    _(@kids).each (v)-> v.remove()  if v
    @

  _addItem: (model)->
    return  unless model  # NOTE convenience
    @_changed_items.push model
    @_throttled_bound_onCollectionChange()

  _addItUp: ->
    return @_throttled_bound_onCollectionChange()  unless @_isOrderValid()
    loop
      return  unless model = @_changed_items.shift()
      view = => @kids[model.id] ||= new FriendsApp::ItemView(model: model, dad: @).render()
      if @_insertInPlace(model, view)
        @_addItem model.prev_crush()
        @_addItem model.next_crush()
        @_throttled_bound_onFilter()
        @_scrollTo view()  if view() == @_cached_first
        @trigger 'insert'
        break

  _isOrderValid: ->  # NOTE kinda order changes atomicity shim
    count = 0
    model = @collection.findWhere(prev_crush_friend_id: null)
    while model
      count++
      model = model.next_crush()
    return false  unless count == @collection.size()

    count = 0
    model = @collection.findWhere(next_crush_friend_id: null)
    while model
      count++
      model = model.prev_crush()
    return count == @collection.size()

  _insertInPlace: (model, view)->
    if prev = model.prev_crush()
      if prev_view = @kids[prev.id]
        if view() != prev_view._cached_next
          #remove
          view()._cached_prev._cached_next = view()._cached_next  if view()._cached_prev
          view()._cached_next._cached_prev = view()._cached_prev  if view()._cached_next
          #insert
          view()._cached_prev = prev_view
          view()._cached_next = prev_view._cached_next
          prev_view._cached_next._cached_prev = view()  if prev_view._cached_next
          prev_view._cached_next = view()
          view().$el.insertAfter prev_view.$el
    else
      if view() != @_cached_first
        #remove
        view()._cached_prev._cached_next = view()._cached_next  if view()._cached_prev
        view()._cached_next._cached_prev = view()._cached_prev  if view()._cached_next
        #insert
        view()._cached_prev = null
        view()._cached_next = @_cached_first
        @_cached_first._cached_prev = view()  if @_cached_first
        @_cached_first = view()
        view().$el.prependTo @$el

  _removeItem: (model)->
    @listenToOnce @kids[model.id], 'remove:ready', ->
      @kids[model.id].remove()
      @_throttled_bound_onResize()
      delete @kids[model.id]
    @kids[model.id].trigger 'remove'

  _onFilter: (str)->
    @_filter_str = str
    @_throttled_bound_onFilter()

  _dofilter: ->
    _(@kids).each (child)=>
      child.$el.toggle !@_filter_str || child.model.match(@_filter_str)
    @_throttled_bound_onResize()

  _bindGlobal: ->
    $(document).on 'scroll', @_throttled_bound_onScroll
    $(window).on 'resize', @_throttled_bound_onResize

  _unbindGlobal: ->
    $(document).off 'scroll', @_throttled_bound_onScroll
    $(window).off 'resize', @_throttled_bound_onResize

  _triggerScroll: (resizing)->
    top = $(document).scrollTop()
    @trigger 'scroll', top, top + $(window).height(), resizing

  _scrollTo: (child)->
    $animateScrollDocumentTo child.$el.position().top
