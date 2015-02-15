TARGET_SCENE_WIDTH = 750
TARGET_SCENE_HEIGHT = 6500

zoomPx = (l, zoom)-> "#{Math.round zoom * l}px"


class Layer
  topOffset: 0
  constructor: (el)->
    @$el = $("##{el}").addClass(el)
  resize: (zoom)->
    @zoom = zoom
    @realTop = @$el.position().top / @zoom
    @$el.css(
      'background-position': "0 #{@_zoomPx @topOffset}"
    )
  render: ->
  _zoomPx: (l)->
    zoomPx l, @zoom

class ScrollableLayer extends Layer
  scrollRatio: 1
  scroll: (top)->
    @targetTop = top / @zoom
  render: ->
    super
    diff = @scrollRatio * @targetTop - @realTop
    if Math.abs(diff) > 1
      @realTop += diff/2
      @$el.css top: @_zoomPx -@realTop

class ScrollableAppearableLayer extends ScrollableLayer
  appearTop: -999
  disappearTop: 999999
  constructor: ->
    super
    @realOpacity = if @$el.is(':visible') then 1 else 0
  render: ->
    super
    targetOpacity =
      if @realTop >= @appearTop && @realTop < @disappearTop then 1 else 0
    diff = targetOpacity - @realOpacity
    if Math.abs(diff) > 0.01
      @realOpacity += diff/2
      @$el.css(
        opacity: @realOpacity
        display: if @realOpacity < 0.05 then 'none' else 'block'
      )

class BackgroundLayer extends ScrollableLayer
  scrollRatio: 0.5

class EventsLayer extends ScrollableAppearableLayer
  topOffset: 150
  scrollRatio: 2
  appearTop: 2*1800
  disappearTop: 2*4200

class StoryLayer extends ScrollableAppearableLayer
  topOffset: 900
  appearTop: 1300

class SnapLayer extends ScrollableAppearableLayer
  topOffset: 150
  disappearTop: 1200

class FunctionLayer extends ScrollableLayer
  resize: ->
    super
    @$el.find('.tagline').css(
      height: @_zoomPx 120
      padding: @_zoomPx 18
    )
    @$el.find('.description').css(
      height: @_zoomPx 1100
      'margin-top': @_zoomPx 18
      padding: @_zoomPx 18
    )
  render: ->
    super
    spacer_height =
      if @realTop < 1280
        1650
      else
        5400
    if spacer_height != @spacer_height
      @spacer_height = spacer_height
      @$el.find('.login-spacer').css(
        height: @_zoomPx @spacer_height
      )

window.crushLand = ->
  layers = [
    new BackgroundLayer 'bg-layer'
    new EventsLayer 'events-layer'
    new StoryLayer 'story-layer'
    new SnapLayer 'snap-layer'
    new FunctionLayer 'function-layer'
  ]

  updateLayout = ->
    $scene = $('#intro')

    width = $(window).width()
    scene =
      if width > TARGET_SCENE_WIDTH
        width: TARGET_SCENE_WIDTH
        left: (width - TARGET_SCENE_WIDTH)/2
      else
        width: width
        left: 0

    zoom = scene.width / TARGET_SCENE_WIDTH

    $scene.css(
      height: zoom * TARGET_SCENE_HEIGHT
      'font-size': zoomPx(18, zoom)
    )
    $scene.find('.layers').css scene

    _(layers).each (layer)->
      layer.resize zoom

  updateScene = ->
    _(layers).each (layer)->
      realTop = $(window).scrollTop()
      layer.scroll realTop

  updateBoth = ->
    updateLayout()
    updateScene()

  updateBoth()

  renderLayers = ->
    _(layers).each (layer)-> layer.render()
    _(renderLayers).delay 64
  renderLayers()

  $(window).on 'resize', _(updateBoth).throttle 198
  $(window).on 'scroll', _(updateScene).throttle 32

  # XXX
  # _(->
  #   scroll = 0
  #   setInterval(
  #     ->
  #       $(window).scrollTop $(window).scrollTop() + 2
  #     64
  #   )
  # ).delay 6666
