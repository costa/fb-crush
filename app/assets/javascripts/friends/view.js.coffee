#= require templates/friends/_friend
#= require templates/users/_user_badge

class ItemView extends Backbone.View

  className:
    'friend visibility-none panel pull-left'

  events:
    'click .intention': 'intent'


  initialize: (options)->
    @dad = options.dad
    super

  render: ->
    # layout
    @$el.html JST['friends/friend']
      friend_button_to: (intention, body_gen)=>
        "<button type=\"button\" class=\"intention btn btn-#{@_intention_class intention}\" data-intention=\"#{intention}\">" +
          body_gen() +
          "</button>"
      friend_user_badge:
        JST['users/user_badge']
          user_name: @model.get 'user_name'
          user_pic_url: @model.get 'user_pic_url'

    # react
    @listenTo @dad, 'scroll', @_onScroll

    @listenTo @model, 'change', -> @_renderState()

    @listenTo @model, 'request', -> @_renderState 'sync'
    @listenTo @model, 'sync error', -> @_renderState 'friendly'

    @listenTo @model, 'error', (_, jqXHR)->  # XXX binding here because the error handling UX must be local (and nicer)
      errors = JSON.stringify jqXHR.responseJSON?.errors || 'Xc:)'  # XXX tmp - other errors
      flash_error I18n.t 'alert', errors: errors, scope: 'friends.flash.update'
    @listenTo @model, 'change:intention', ->
      flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice'
    @listenTo @model, 'change:is_mutual_intention', ->  # XXX doesn't really work without real-time data channel updates
      if @model.isMutualIntention()
        flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice.mutual'

    @on 'remove', -> @_renderState 'fini'
    @listenTo @model, 'destroy', -> @_renderState 'fini'
    @_renderState 'friendly'

    @


  _onScroll: (top, bottom, resizing)->
    visibility_was = @_visibility
    @_visibility = @_visibilityIn top, bottom, resizing
    if visibility_was != @_visibility
      @$el.removeClass 'visibility-' + visibility_was
      @$el.addClass 'visibility-' + @_visibility

  _renderState: (state)->
    prev_state = @_render_state
    @_render_state =
      if state?
        state
      else
        switch prev_state
          when 'friendly'
            if @model.get 'intention'
              if @model.isMutualIntention()
                'mutual'
              else
                'crushed'
            else
              'friendly'
          when 'crushed', 'mutual'
            'friendly'
          when 'fini'
            @trigger 'remove:ready'
          else
            prev_state

    ani_delay = @dad.collection.size()*20
    rand_delay = (x)-> x * ani_delay * Math.random()
    dim_percent = (x)->
      width: "#{x}%"
      height: "#{x}%"

    if @_render_state == 'sync'
      @$("[data-intention]").prop 'disabled', true
    else
      @$("[data-intention]").prop 'disabled', false
      @$("[data-intention=#{@model.Get 'intention'}]").prop 'disabled', true

    @$el.removeClass 'panel-danger panel-default'
    if @_render_state == 'mutual'
      @$el.addClass "panel-#{@_intention_class @model.get 'intention'}"

    $el = @$('.picture img')
    switch @_render_state
      when 'crushed'
        $el.
          animate(dim_percent(75), 'slow').
          animate(dim_percent(90), 'slow').
          animate(dim_percent(75), 'slow').
          animate(dim_percent(80), 'slow')
      when 'mutual'
        $el.
          animate(dim_percent(75), 'fast').
          animate(dim_percent(90), 'fast').
          animate(dim_percent(75), 'fast').
          animate(dim_percent(80), 'fast')
      when 'fini'
        $el.
          delay(rand_delay 1).
          animate(dim_percent(100)).
          animate(dim_percent(10), 'fast')

    unless @_render_state == prev_state
      $el.queue (next)=>
        @_renderState()
        next()

  intent: (e)->
    @model.intent $(e.target).data('intention')

  _visibilityIn: (top, bottom, resizing)->
    if resizing || !@_el_top? || !@_el_bottom?
      @_el_top = @$el.offset().top
      @_el_bottom = @_el_top + @$el.height()

    if @_el_top > top && @_el_bottom < bottom
      if Math.abs((@_el_top - top) - (bottom - @_el_bottom)) < @_el_bottom - @_el_top
        'full'
      else
        'some'
    else
      'none'

  _intention_class: (intention)->
    if intention == 'love' then 'danger' else 'default'


window.FriendsApp ||= {}
class FriendsApp.ListView extends Backbone.View
  el: '#friends'

  initialize: ->
    @_throttled_bound_onScroll = _(=> @_triggerScroll()).throttle 150, leading: false
    @_throttled_bound_onResize = _(=> @_triggerScroll true).throttle 150, leading: false
    super

  render: ->
    addItemFor = (friend)=>
      view = new ItemView(model: friend, dad: @).render()  # XXX some potential for optimisation here
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
