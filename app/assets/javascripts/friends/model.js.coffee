class FriendsApp::Friend extends Backbone.Model

  _stripStr = (str)-> str.toLowerCase().replace(/[^a-z0-9]/, '')

  initialize: ->
    @on 'change:user_name', -> @__index_str = null

  match: (str)->
    @_indexStr().indexOf(_stripStr(str)) >= 0

  prev_crush: ->
    @collection.get parseInt @get('prev_crush_friend_id')
  next_crush: ->
    @collection.get parseInt @get('next_crush_friend_id')

  isMutualIntention: ->
    !!@get('is_mutual_intention')

  intention: ->
    @get('intention') || 'none'

  intent: (intention)->
    @save {intention: intention || null}, patch: true, wait: true

  _indexStr: ->
    @__index_str || = _stripStr @get('user_name')


class FriendsApp::Friends extends Backbone.Collection

  model: FriendsApp::Friend

  initialize: (models, options)->
    @url = options.url
    super
