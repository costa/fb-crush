#= require templates/friends/_friend
#= require templates/users/_user_badge

class ItemView extends Backbone.View

  className:
    'friend panel pull-left'

  events:
    'click .intention': 'intent'


  initialize: (options)->
    super

    @dad = options.dad
    @render().$el.appendTo @dad.$el

    @listenTo @dad, 'scroll', -> @_renderState()  # NOTE 'scroll' is throttled
    @listenTo @model, 'change', -> @_renderState()

    @listenTo @model, 'request', -> @_renderState 'sync'
    @listenTo @model, 'sync error', -> @_renderState 'waiting'

    @listenTo @model, 'error', (_, jqXHR)->  # XXX binding here because the error handling UX must be local (and nicer)
      errors = JSON.stringify jqXHR.responseJSON?.errors || 'Xc:)'  # XXX tmp - other errors
      flash_error I18n.t 'alert', errors: errors, scope: 'friends.flash.update'
    @listenTo @model, 'change:intention', ->
      flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice'
    @listenTo @model, 'change:is_mutual_intention', ->  # XXX doesn't really work without real-time data channel updates
      if @model.isMutualIntention()
        flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice.mutual'

    @listenTo @model, 'remove destroy', -> @_renderState 'fini'
    @_renderState 'init'

  render: ->
    @$el.html JST['friends/friend']
      friend_button_to: (intention, body_gen)=>
        "<button type=\"button\" class=\"intention btn btn-#{@_intention_class intention}\" data-intention=\"#{intention}\">" +
          body_gen() +
          "</button>"
      friend_user_badge:
        JST['users/user_badge']
          user_name: @model.get 'user_name'
          user_pic_url: @model.get 'user_pic_url'
    @

  remove: ->
    super
    @trigger 'removed'

  _renderState: (state)->
    prev_state = @_render_state
    @_render_state =
      if state?
        state
      else
        switch prev_state
          when 'init'
            'waiting'
          when 'waiting'
            if @isVisible()
              'showing'
            else
              'waiting'
          when 'showing'
            'friendly'
          when 'friendly'
            if @isVisible()
              if @model.get 'intention'
                if @model.isMutualIntention()
                  'mutual'
                else
                  'crushed'
              else
                'friendly'
            else
              'hiding'
          when 'crushed', 'mutual'
            'friendly'
          when 'hiding'
            'waiting'
          when 'fini'
            @remove()
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
      when 'init'
        $el.
          css(dim_percent 10)
      when 'showing'
        $el.
          delay(rand_delay 1).
          animate(dim_percent(100)).
          animate(dim_percent(80), 'fast')
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
      when 'hiding'
        $el.
          delay(rand_delay 1).
          animate(dim_percent(100), 'fast').
          animate(dim_percent(10))
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

  isVisible: ->
    el_top = @$el.offset().top
    doc_top = $(document).scrollTop()
    el_top > doc_top && el_top + @$el.height() < doc_top + $(window).height()

  _intention_class: (intention)->
    if intention == 'love' then 'danger' else 'default'


window.FriendsApp ||= {}
class FriendsApp.ListView extends Backbone.View

  el: '#friends'

  initialize: ->
    @kids = {}

  render: ->
    @remove()
    add_it = (friend)=>
      @kids[friend.id] = new ItemView model: friend, dad: @
    @collection.each add_it
    @listenTo @collection, 'add', add_it
    @listenTo @collection, 'remove', (friend)=>  # NOTE the kid view is supposed to receive the same remove event from backbone
      @listenToOnce @kids[friend.id], 'removed', => # and then emit the (post mortem) 'removed' event when done
        delete @kids[friend.id]
    @_bindGlobal()
    @

  remove: ->
    @_unbindGlobal()
    _(@kids).each (v)-> v.remove()
    @kids = {}
    @stopListening()

  _bindGlobal: ->
    @__throttledWindowScroll = _(=> @trigger 'scroll').throttle @collection.size()  # XXX better throttling euristics
    $(window).on 'scroll', @__throttledWindowScroll

  _unbindGlobal: ->
    $(window).off 'scroll', @__throttledWindowScroll  if @__throttledWindowScroll?
    delete @__throttledWindowScroll
