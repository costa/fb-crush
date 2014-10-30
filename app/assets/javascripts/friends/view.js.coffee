#= require templates/friends/index
#= require templates/friends/_friend
#= require templates/users/_user_badge

class ItemView extends Backbone.View
  events:
    'click .intention': 'intent'

  initialize: (options)->
    super

    @model.on 'sync error', -> location.reload()  # XXX TMP!

    @dad = options.dad
    @render().$el.appendTo @dad.$('.pool')

  render: ->
    I18n.localScope = 'friends.friend'
    intention_class = (intention)->
      if intention == 'love' then 'danger' else 'default'

    @$el.html JST['friends/friend']
      friend_intention_class:
        if @model.isMutualIntention()
          "alert alert-#{intention_class model.get 'intention'}"
        else
          'well'
      friend_button_to: (intention, body_gen)->
        "<button type=\"button\" class=\"intention btn btn-#{intention_class intention}\" data-intention=\"#{intention}\">" +
          body_gen() +
          "</button>"
      friend_user_badge:
        JST['users/user_badge']
          user_name: @model.get 'user_name'
          user_pic_url: @model.get 'user_pic_url'

    @$("[data-intention=#{@model.Get 'intention'}]").prop 'disabled', true

    @

  intent: (e)->
    @model.intent $(e.target).data('intention')


window.FriendsApp ||= {}
class FriendsApp.ListView extends Backbone.View
  el: '#friends'

  render: ->
    I18n.localScope = 'friends.index'

    @$el.html JST['friends/index']
      friends_count: @collection.size()
    @kids = @collection.map (friend)-> new ItemView model: friend, dad: @
    @

  remove: ->
    @kids?.each (view)-> view.remove()
    @$el.html()
    @stopListening()
