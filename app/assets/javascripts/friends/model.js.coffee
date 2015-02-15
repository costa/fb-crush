class FriendsApp::Friend extends Backbone.Model

  isMutualIntention: ->
    !!@get('is_mutual_intention')

  intention: ->
    @get('intention') || 'none'

  intent: (intention)->
    @save {intention: intention || null}, patch: true, wait: true


class FriendsApp::Friends extends Backbone.Collection

  model: FriendsApp::Friend
  comparator: (friend)->
    console.log new Date(friend.get('updated_at')).getTime()
    - new Date(friend.get('updated_at')).getTime()

  initialize: (models, options)->
    @url = options.url
    super
