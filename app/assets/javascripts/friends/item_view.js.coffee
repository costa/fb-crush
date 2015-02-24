#= require templates/friends/_friend
#= require templates/users/_user_badge
class FriendsApp::ItemView extends Backbone.View

  className:
    'friend'

  events:
    'click .intention': '_onIntent'

  initialize: (options)->
    @dad = options.dad
    super

  render: ->

    @listenTo @dad, 'scroll', @_updateVisibility
    # NOTE the parent have to trigger scroll after render
    @listenTo @model, 'change:intention change:is_mutual_intention', _(=> @_updateIntentness()).throttle 300, leading: false
    @_updateIntentness true

    @on 'remove', @_removeAsync

    @listenTo @model, 'error', (_, jqXHR)->
      errors = JSON.stringify jqXHR.responseJSON?.errors || 'Xc:)'  # XXX tmp - other errors
      flash_error I18n.t 'alert', errors: errors, scope: 'friends.flash.update'
    @

  _renderTemplateOnce: ->
    return  if @_templateOnceRendered
    @_templateOnceRendered = true

    @$el.html JST['friends/friend']
      friend_button_to: (intention, body_gen)=>
        "<button type=\"button\" class=\"intention btn btn-sm btn-#{@_intention_class intention}\" data-intention=\"#{intention}\">" +
          body_gen() +
          "</button>"
      friend_user_badge:
        JST['users/user_badge']
          user_name: @model.get 'user_name'
          user_pic_url: @model.get 'user_pic_url'

    @listenTo @model, 'request', @_disableControls
    @listenTo @model, 'sync error change:intention', @_enableControls
    @_enableControls()

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

  _updateIntentness: (skip_fx)->
    intentness_was = @__intentness
    @__intentness = @_intentness()
    if intentness_was != @__intentness
      unless skip_fx
        if @__intentness == 'full'
          flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice.mutual'
        else
          flash_notice I18n.t @model.intention(), name: @model.get('user_name'), scope: 'friends.flash.update.notice'
      @$el.removeClass 'intentness-' + intentness_was  if intentness_was
      @$el.addClass 'intentness-' + @__intentness  if @__intentness

  _updateVisibility: (top, bottom, resizing)->
    visibility_was = @__visibility
    @__visibility = @_visibilityIn top, bottom, resizing
    if visibility_was != @__visibility
      if visibility_was
        @$el.removeClass 'visibility-' + visibility_was
      if @__visibility
        @_renderTemplateOnce()
        @$el.addClass 'visibility-' + @__visibility

  _onIntent: (e)->
    @model.intent $(e.target).data('intention')

  _visibilityIn: (top, bottom, resizing)->
    return  unless @$el.is(':visible')

    if resizing || !@_el_top? || !@_el_bottom?
      @_el_top = @$el.offset().top
      @_el_bottom = @_el_top + @$el.height()

    if @_el_bottom > top && @_el_top < bottom
      if Math.abs((@_el_top - top) - (bottom - @_el_bottom)) < @_el_bottom - @_el_top
        'full'
      else
        'some'

  _intentness: ->
    if @model.get 'intention'
      if @model.isMutualIntention()
        'full'
      else
        'half'

  _intention_class: (intention)->
    if intention == 'love' then 'danger' else 'default'
