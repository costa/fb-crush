class Friend extends Backbone.Model

  isMutualIntention: ->
    !!@get('is_mutual_intention')
  intent: (intention)->
    @set 'intention', intention
    @save()
  toJSON: (options)->
    friend:
      intention: @get 'intention'


window.FriendsApp ||= {}
class FriendsApp.Friends extends Backbone.Collection
  model: Friend

  initialize: (models, options)->
    @url = options.url
    super
