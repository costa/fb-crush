class FriendsApp::Friend extends Backbone.Model

  isMutualIntention: ->
    !!@get('is_mutual_intention')

  intention: ->
    @get('intention') || 'none'

  intent: (intention)->
    @save {intention: intention || null}, patch: true, wait: true

  prev_crush: ->
    @collection.get parseInt @get('prev_crush_friend_id')
  next_crush: ->
    @collection.get parseInt @get('next_crush_friend_id')


class FriendsApp::Friends extends Backbone.Collection

  model: FriendsApp::Friend

  initialize: (models, options)->
    @url = options.url
    super
