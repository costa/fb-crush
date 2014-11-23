class Friend extends Backbone.Model

  isMutualIntention: ->
    !!@get('is_mutual_intention')

  intention: ->
    @get('intention') || 'none'

  intent: (intention)->
    @save {intention: intention || null}, patch: true, wait: true


window.FriendsApp ||= {}
class FriendsApp.Friends extends Backbone.Collection

  model: Friend

  initialize: (models, options)->
    @url = options.url
    super
