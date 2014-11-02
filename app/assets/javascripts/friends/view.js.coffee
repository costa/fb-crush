#= require templates/friends/_friend
#= require templates/users/_user_badge

class ItemView extends Backbone.View
  events:
    'click .intention': 'intent'
  className: ->
    "friend pull-left panel panel-#{@_intention_class @model.isMutualIntention() && @model.get 'intention' || ''}"

  initialize: (options)->
    super

    @listenTo @model, 'sync error', -> location.reload()  # XXX TMP!

    @dad = options.dad
    @render().$el.appendTo @dad.$el
    @on 'scroll', @_renderState
    @_renderState 'init'

  render: ->
    I18n.localScope 'friends.friend', =>
      @$el.html JST['friends/friend']
        friend_button_to: (intention, body_gen)=>
          "<button type=\"button\" class=\"intention btn btn-#{@_intention_class intention}\" data-intention=\"#{intention}\">" +
            body_gen() +
            "</button>"
        friend_user_badge:
          JST['users/user_badge']
            user_name: @model.get 'user_name'
            user_pic_url: @model.get 'user_pic_url'

    @$("[data-intention=#{@model.Get 'intention'}]").prop 'disabled', true

    @

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
          else
            prev_state

    ani_delay = @dad.collection.size()*20
    rand_delay = (x)-> x * ani_delay * Math.random()
    dim_percent = (x)->
      width: "#{x}%"
      height: "#{x}%"

    $el = @$('.picture img')
    switch @_render_state
      when 'init'
        $el.
          css(dim_percent 10)
      when 'showing'
        $el.
          delay(rand_delay 1).
          animate(dim_percent 100).
          animate(dim_percent 80, 'fast')
      when 'crushed'
        $el.
          animate(dim_percent 75, 'slow').
          animate(dim_percent 90, 'slow').
          animate(dim_percent 75, 'slow').
          animate(dim_percent 80, 'slow')
      when 'mutual'
        $el.
          animate(dim_percent 75, 'fast').
          animate(dim_percent 90, 'fast').
          animate(dim_percent 75, 'fast').
          animate(dim_percent 80, 'fast')
      when 'hiding'
        $el.
          delay(rand_delay 1).
          animate(dim_percent 100, 'fast').
          animate(dim_percent 10)

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

  render: ->
    @remove()
    @kids = @collection.map (friend)=> new ItemView model: friend, dad: @
    @kids = _(@kids).chain()  # Underscore. Don't ask.
    @_bindGlobal()

    @

  remove: ->
    @_unbindGlobal()
    @kids?.each (v)-> v.remove()
    @kids = null
    @$el.html()
    @stopListening()

  _bindGlobal: ->
    @__scrollKids = _(=>
      @kids.each (v)-> v.trigger('scroll')
      ).throttle(333)
    $(window).on 'scroll', @__scrollKids

  _unbindGlobal: ->
    $(window).off 'scroll', @__scrollKids  if @__scrollKids?
    @__scrollKids = null
