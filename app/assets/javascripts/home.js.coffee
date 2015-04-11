SCENE_WIDTH = 750
SCENE_HEIGHT = 7600
SHORT_SCENE_HEIGHT = 2600
LONG_SCENE_HEIGHT = 5000  # don't ask


class ContentControl extends Backbone.View
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
  SCROLL_THROTTLE = 13
  MIN_LAYER_SCROLL = 2
  MAX_SCROLL_PX_MS = 1
  MAX_LAYER_SCROLL = MAX_SCROLL_PX_MS * SCROLL_THROTTLE

  initialize: (options)->
    super
    @_throttled_bound_smoothScroll = _(=> @_smoothScroll()).throttle SCROLL_THROTTLE, leading: false
    _(@).extend _(options).pick 'parent', 'layers'
  render: ->
    @listenTo @parent, 'zoom', @_zoom
    @listenTo @parent, 'scroll', @_scroll
    @_prop_values = {}
    @_renderLayers()
    @
  _removeElement: ->  # NOTE do NOT remove @$el
  _renderLayers: ->
    _(@layers).each (layer)=>
      @$el.append layer.$el
  _zoom: ->
    _(@layers).each (layer)=>
      layer.zoomWith @parent
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

class EventsLayer extends YaaniLayer::ScrollableAppearable
  setToShow: ->
    @appear_top = 1500
    @disappear_top = 5400

class Scene extends Backbone.View
  events:
    'click .chevron .down': '_expand'
    'click .chevron .up': '_contract'
  initialize: ->
    super
    @_throttled_bound_zoom = _(=> @_zoom()).throttle 900
    @_bound_disableAutoScroll = => @_disableAutoScroll()
    @_throttled_bound_triggerScroll = _(=> @_triggerScroll()).throttle 150
    @game = 'crush'
    @_layers =
      bg: new YaaniLayer::Scrollable className: @_theme('bg-layer'), scrollRatio: 0.5
      events: new EventsLayer className: @_theme('events-layer'), scrollRatio: 2
  render: ->
    $('body').addClass @game
    @_bg_view ||= new LayeredBackground(
      el: @$('.bg-layers')
      parent: @
      layers: _pickValues(@_layers, 'bg', 'events')
    ).render()
    @_cont_view ||= new ContentControl(
      el: @$('.content')
      parent: @
    ).render()
    @_initStory()
    @_throttled_bound_zoom()
    @_bindGlobal()
    @trigger 'ready'
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

  _initStory: ->
    @nominal_height = SHORT_SCENE_HEIGHT
    @$el.removeClass 'full-story'
    @_hideLayers 'events'
    @_bg_view.inert = true
  _fullStory: ->
    @nominal_height = LONG_SCENE_HEIGHT
    @$el.addClass 'full-story'
    @_showLayers 'events'
    @_bg_view.inert = false

  _contract: ->
    return  unless @_expanded
    @_expanded = false
    $animateScrollDocumentTo 0
    @$el.animate(opacity: 0, 2000).queue((next)=>
      @_initStory()
      @_throttled_bound_zoom()
      next()
    ).animate(opacity: 1, 2000)
  _expand: ->
    return  if @_expanded
    @_expanded = true
    $animateScrollDocumentTo 0
    @$el.animate(opacity: 0, 2000).queue((next)=>
      @_fullStory()
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
        $(document).scrollTop $(document).scrollTop() + 2
      _(roll).delay 99  if @_expanded
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
    $(window).on 'touchstart touchmove touchend wheel mousewheel', @_bound_disableAutoScroll
    $(document).on 'scroll', @_throttled_bound_triggerScroll

  _unbindGlobal: ->
    $(window).off 'resize', @_throttled_bound_zoom
    $(window).off 'touchstart touchmove touchend wheel mousewheel', @_bound_disableAutoScroll
    $(document).off 'scroll', @_throttled_bound_triggerScroll

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

  _disableAutoScroll: ->
    @_just_scrolled = true

  _triggerScroll: ->
    @trigger 'scroll', $(document).scrollTop() / @zoom


window.crushLand = ->
  scene = new Scene(el: $('main').addClass('scene'))
  scene.on 'ready', ->
    scene.$('.loading-page').fadeOut('slow')
  scene.render()
