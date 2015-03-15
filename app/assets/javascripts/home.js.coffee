SCENE_WIDTH = 750
SCENE_HEIGHT = 7600
SHORT_SCENE_HEIGHT = 2600
LONG_SCENE_HEIGHT = 5000  # don't ask


class ContentControl extends Backbone.View
  inert: true
  initialize: (options)->
    super
    @parent = options.parent
    @_throttled_bound_fixTextBlocks = _(=> @_fixTextBlocks()).throttle 150
  render: ->
    @$('.text-blk').addClass 'front'
    @listenTo @parent, 'zoom scroll', @_throttled_bound_fixTextBlocks
    @
  _removeElement: ->  # NOTE do NOT remove @$el
  _fixTextBlocks: ->
    @_$login ||= @$('.login-blk')
    login_top = @_$login.offset().top
    $back_up_cont = @$('.sub-titles')
    changed = false
    @$('.text-blk').reverse().each (i, el)=>  # XXX yeah, it was quick and dirty
      $blk = $(el)
      bottom = $blk.offset().top + $blk.height()
      if bottom < login_top
        if back_up_id = $blk.data('back_up_id')
          $blk.data 'back_up_id', null
          $("##{back_up_id}").
            slideUp
              complete: @_throttled_bound_fixTextBlocks
              done: -> $(@).remove()
          $blk.addClass 'front'
          return false
      else
        unless $blk.data('back_up_id')
          $blk.removeClass 'front'
          $("<div id='#{next_back_up_id}'>").hide().
            html($blk.html()).
            prependTo($back_up_cont).
            slideDown()
          $blk.data 'back_up_id', next_back_up_id
          next_back_up_id += 1
          @_throttled_bound_fixTextBlocks()
          return false
    @_$login.toggleClass 'at-bottom', $back_up_cont.is(':empty')
  next_back_up_id = 1111

class LayeredBackground extends Backbone.View
  MIN_LAYER_SCROLL = 2
  MAX_SCROLL_PX_MS = 1
  SCROLL_THROTTLE = 13
  MAX_LAYER_SCROLL = MAX_SCROLL_PX_MS * SCROLL_THROTTLE

  initialize: (options)->
    super
    @_throttled_bound_smoothScroll = _(=> @_smoothScroll()).throttle SCROLL_THROTTLE
    _(@).extend _(options).pick 'parent', 'layers'
  render: ->
    @listenTo @parent, 'zoom', @_zoom
    @listenTo @parent, 'scroll', @_scroll
    @_prop_values = {}
    @_renderLayers()
  _removeElement: ->  # NOTE do NOT remove @$el
  _renderLayers: ->
    bgs = _(@layers).chain().map((layer)->  layer.background).compact().value().reverse()
    _(YaaniLayer::ScrollableAppearable::background_props).each (prop)=>
      new_prop_value = _(bgs).map((bg)-> bg[prop]).join(',')
      if @_prop_values[prop] != new_prop_value
        @$el.css(
          "background-#{prop}": new_prop_value
        )
        @_prop_values[prop] = new_prop_value
  _zoom: ->
    _(@layers).each (layer)=>
      layer.zoomWith @parent
    @_renderLayers()
  _scroll: (top)->
    @_next_top = top
    @_inertia_top = null
    @_throttled_bound_smoothScroll()
  _smoothScroll: ->
    @_actual_top ||= 0
    diff =
      if @_inertia_top
        @_inertia_top - @_actual_top
      else
        @_next_top - @_actual_top
    abs_diff = Math.abs(diff)
    @_actual_top +=
      if abs_diff < MIN_LAYER_SCROLL
        if @_inertia_top
          _(@_throttled_bound_smoothScroll).defer()
          if Math.abs(@_inertia_top - @_next_top) < MIN_LAYER_SCROLL
            @_inertia_top = null
          else
            @_inertia_top = @_next_top - (@_next_top - @_inertia_top)/2
        diff
      else
        _(@_throttled_bound_smoothScroll).defer()
        if abs_diff > MAX_LAYER_SCROLL
          parseInt (diff/abs_diff)*MAX_LAYER_SCROLL
        else
          if @_inertia_top
            parseInt diff/2
          else
            @_inertia_top = @_next_top + diff/2  if @inert
            diff
    _(@layers).each (layer)=>
      layer.scroll @_actual_top
    @_renderLayers()

class BackgroundLayer extends YaaniLayer::Scrollable
  scroll_ratio: 0.5

class EventsLayer extends YaaniLayer::ScrollableAppearable
  scroll_ratio: 2
  setToShow: ->
    @appear_top = 1500
    @disappear_top = 5400

class StoryLayer extends YaaniLayer::ScrollableAppearable

class SnapLayer extends YaaniLayer::ScrollableAppearable

class Scene extends Backbone.View
  events:
    'click .chevron .down': '_expand'
    'click .chevron .up': '_contract'
  initialize: ->
    super
    @_throttled_bound_zoom = _(=> @_zoom()).throttle 900
    @_throttled_bound_scroll = _(=> @_scroll()).throttle 150
    @game = 'crush'
    @_layers =
      bg: new BackgroundLayer @_theme 'bg-layer'
      events: new EventsLayer @_theme 'events-layer'
      story: new StoryLayer @_theme 'story-layer'
      snap: new SnapLayer @_theme 'snap-layer'
  render: ->
    $('body').addClass @game
    @_init_story()
    @_bg_view ||= new LayeredBackground(
      el: @$('.bg-layers')
      parent: @
      layers: _pickValues(@_layers, 'bg', 'events', 'story', 'snap')
    ).render()
    @_cont_view ||= new ContentControl(
      el: @$('.content')
      parent: @
    ).render()
    @_throttled_bound_zoom()
    @_bindGlobal()
    @
  remove: ->
    @_unbindGlobal()
    @_cont_view.remove()
    @_cont_view = null
    @_bg_view.remove()
    @_bg_view = null
    $('body').removeClass(@game).css height: ''
    @

  zoomPx: (l)->
    "#{Math.round @zoom * l}px"

  _init_story: ->
    @nominal_height = SHORT_SCENE_HEIGHT
    @$el.removeClass 'full-story'
    @_hideLayers 'story', 'events'
    @_showLayers 'snap'
    @_cont_view.inert = true  if @_cont_view
  _full_story: ->
    @nominal_height = LONG_SCENE_HEIGHT
    @$el.addClass 'full-story'
    @_hideLayers 'snap'
    @_showLayers 'story', 'events'
    @_cont_view.inert = false  if @_cont_view

  _contract: (force)->
    return  unless force || @_expanded
    @_expanded = false
    $animateScrollDocumentTo 0
    @$el.animate(opacity: 0, 2000).queue((next)=>
      @_init_story()
      @_throttled_bound_zoom()
      next()
    ).animate(opacity: 1, 2000)
  _expand: ->
    return  if @_expanded
    @_expanded = true
    $animateScrollDocumentTo 0
    @$el.animate(opacity: 0, 2000).queue((next)=>
      @_full_story()
      @_throttled_bound_zoom()
      next()
    ).animate(opacity: 1, 2000)
    roll = =>
      if @_just_scrolled
        @_just_scrolled = false
        @_auto_scroll_disabled = true
        clearTimeout @_just_scrolled_timer
        @_just_scrolled_timer = setTimeout(
          => @_auto_scroll_disabled = false
        , 2000)
      unless @_auto_scroll_disabled
        @_just_auto_scrolled = true
        $(document).scrollTop $(document).scrollTop() + 1
      _(roll).delay 14  if @_expanded
    _(roll).delay 2000

  _hideLayers: (layers...)->
    _(_pickValues(@_layers, layers...)).each (layer)-> layer.setToHide()
  _showLayers: (layers...)->
    _(_pickValues(@_layers, layers...)).each (layer)-> layer.setToShow()

  _theme: (asset)->
    "#{@game}-#{asset}-#{SCENE_WIDTH}x#{SCENE_HEIGHT}"

  _bindGlobal: ->
    @_unbindGlobal()
    $(window).on 'resize', @_throttled_bound_zoom
    $(document).on 'scroll', @_throttled_bound_scroll

  _unbindGlobal: ->
    $(window).off 'resize', @_throttled_bound_zoom
    $(document).off 'scroll', @_throttled_bound_scroll

  _zoom: ->
    width = $(window).width()
    @zoom =
      if width > SCENE_WIDTH
        1
      else
        width / SCENE_WIDTH

    # XXX CSS this
    $('body').css height: @zoomPx @nominal_height
    @$('.fixed-width').andSelf().css width: @zoomPx SCENE_WIDTH
    @$el.height @zoomPx SCENE_HEIGHT
    @$el.css 'font-size': @zoomPx(18)

    @trigger 'zoom'

  _scroll: ->
    if @_just_auto_scrolled
      @_just_auto_scrolled = false
    else
      @_just_scrolled = true
    @trigger 'scroll', $(document).scrollTop() / @zoom


window.crushLand = ->
  new Scene(el: $('main').addClass('scene')).render()
