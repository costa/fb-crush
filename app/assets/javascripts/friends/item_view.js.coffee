#= require templates/friends/_friend
#= require templates/users/_user_badge
class FriendsApp::ItemView extends Backbone.View

  className:
    'friend visibility-none'

  events:
    'click .intention': '_onIntent'
    'mouseover': '_onHover'

  initialize: (options)->
    @dad = options.dad
    super

  render: ->

    # layout
    @$el.html JST['friends/friend']
      friend_button_to: (intention, body_gen)=>
        "<button type=\"button\" class=\"intention btn btn-sm btn-#{@_intention_class intention}\" data-intention=\"#{intention}\">" +
          body_gen() +
          "</button>"
      friend_user_badge:
        JST['users/user_badge']
          user_name: @model.get 'user_name'
          user_pic_url: @model.get 'user_pic_url'

    # react

    @listenTo @dad, 'scroll', @_updateVisibility
    # NOTE the parent have to trigger scroll after render

    @listenTo @model, 'change:intention change:is_mutual_intention', @_updateIntentness
    @_updateIntentness()

    @on 'remove', @_removeAsync

    @listenTo @model, 'request', @_disableControls
    @listenTo @model, 'sync error change:intention', @_enableControls
    @_enableControls()

    # server (flash) notifications
    # XXX binding here because the error handling UX must be local (and nicer)
    @listenTo @model, 'error', (_, jqXHR)->
      errors = JSON.stringify jqXHR.responseJSON?.errors || 'Xc:)'  # XXX tmp - other errors
      flash_error I18n.t 'alert', errors: errors, scope: 'friends.flash.update'
    @listenTo @model, 'change:intention', ->
      flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice'
    @listenTo @model, 'change:is_mutual_intention', ->  # XXX doesn't really work without real-time data channel updates
      if @model.isMutualIntention()
        flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice.mutual'

    @


  _updateVisibility: (top, bottom, resizing)->
    visibility_was = @__visibility
    @__visibility = @_visibilityIn top, bottom, resizing
    if visibility_was != @__visibility
      @$el.removeClass 'visibility-' + visibility_was
      @$el.addClass 'visibility-' + @__visibility

  _disableControls: ->
    @$("[data-intention]").prop 'disabled', true
  _enableControls: ->
    @$("[data-intention]").prop 'disabled', false
    @$("[data-intention=#{@model.Get 'intention'}]").prop 'disabled', true

  _removeAsync: ->
    return  if @__remove_async?
    @$el.addClass 'removing'
    @__remove_async = _(
      =>
        @trigger 'remove:ready'
        delete @__remove_async
      ).delay 300

  _updateIntentness: ->
    intentness_was = @__intentness
    @__intentness = @_intentness()
    if intentness_was != @__intentness
      @$el.removeClass 'intentness-' + intentness_was
      @$el.addClass 'intentness-' + @__intentness

  _onIntent: (e)->
    @model.intent $(e.target).data('intention')

  _onHover: ->
    @$el.addClass 'hover'
    @__on_hover_timer ||= _(
      =>
        @$el.removeClass 'hover'
        delete @__on_hover_timer
      ).delay 5000

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

  _intentness: ->
    if @model.get 'intention'
      if @model.isMutualIntention()
        'full'
      else
        'half'
    else
      'none'

  _intention_class: (intention)->
    if intention == 'love' then 'danger' else 'default'