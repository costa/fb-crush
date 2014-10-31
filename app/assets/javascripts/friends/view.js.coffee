#= require templates/friends/index
#= require templates/friends/_friend
#= require templates/users/_user_badge

class ItemView extends Backbone.View
  events:
    'click .intention': 'intent'
  className: ->
    "friend pull-left panel panel-#{@_intention_class @model.isMutualIntention() && @model.get 'intention' || ''}"

  initialize: (options)->
    super

    @model.on 'sync error', -> location.reload()  # XXX TMP!

    @dad = options.dad
    @render().$el.appendTo @dad.$('.pool')
    @_render_state 'init'

  render: ->
    I18n.localScope = 'friends.friend'

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

  _render_state: (state)->
    prev_state = @__render_state
    @__render_state =
      if state?
        state
      else
        switch prev_state
          when 'init'
            'friendly'
          else
            prev_state

    ani_delay = @dad.collection.size()*20
    rand_delay = (x)-> x * ani_delay * Math.random()

    switch @__render_state
      when 'init'
        @$('.picture img').
          css(zoom: 0.1).
          delay(rand_delay 1).
          animate({ zoom: 1 }, 'slow').
          animate { zoom: 0.8 }, 'fast', null, =>
            @_render_state()
      when 'friendly'
        @$('.picture img').
          delay(rand_delay 10).
          animate({ zoom: 0.9 }, 'slow').
          animate({ zoom: 0.75 }, 'fast').
          animate { zoom: 0.8 }, 'fast', null, =>
            @_render_state()

  intent: (e)->
    @model.intent $(e.target).data('intention')

  _intention_class: (intention)->
    if intention == 'love' then 'danger' else 'default'


window.FriendsApp ||= {}
class FriendsApp.ListView extends Backbone.View
  el: '#friends'

  render: ->
    I18n.localScope = 'friends.index'

    @$el.html JST['friends/index']
      friends_count: @collection.size()
    @kids = @collection.map (friend)=> new ItemView model: friend, dad: @
    @

  remove: ->
    @kids?.each (view)-> view.remove()
    @$el.html()
    @stopListening()
