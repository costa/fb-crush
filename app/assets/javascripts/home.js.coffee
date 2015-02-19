SCENE_WIDTH = 750
SCENE_HEIGHT = 7600

zoomPx = (l, zoom)-> "#{Math.round zoom * l}px"


class Layer
  topOffset: 0
  constructor: (el)->
    @$el = $("##{el}").addClass(el)
  resize: (zoom)->
    @zoom = zoom
    @$el.css(
      'background-position': "0 #{@zoomPx @topOffset}"
    )
    @realTop = @$el.position().top / @zoom
  render: ->
  zoomPx: (l)->
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
      @$el.css top: @zoomPx -@realTop

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
  appearTop: 2*2100
  disappearTop: 2*5300

class StoryLayer extends ScrollableAppearableLayer
  topOffset: 2000
  appearTop: 2050

class SnapLayer extends ScrollableAppearableLayer
  topOffset: 150
  disappearTop: 1700

class FuncLayer extends ScrollableLayer

  EXPAND_DURATION = 1000

  constructor: (el, parent)->
    super
    @parent = parent
    @$el.find('.chevron .down').on 'click', =>
      $('html, body').animate {scrollTop: parseInt @zoomPx 2100}, 2 * EXPAND_DURATION
      @_expand()
    @$el.find('.chevron .up').on 'click', =>
      $(window).scrollTop parseInt @zoomPx 1200
      @_contract()
    @_renderLogin true
  resize: ->
    super
    @$el.find('.tagline').css(
      height: @zoomPx 120
      padding: @zoomPx 18
    )
    @$el.find('.description').css(
      height: @zoomPx 1050
      'margin-top': @zoomPx 18
      padding: @zoomPx 18
    )
    @_renderLogin()
  scroll: ->
    super
    if @realTop < 500
      @_contract()
  _contract: ->
    return  unless @_expanded
    @_expanded = false
    @_mustContract = false
    @_renderLogin()
  _expand: ->
    return  if @_expanded
    @_expanded = true
    roll = =>
      $(window).scrollTop $(window).scrollTop() + 1
      _(roll).delay 50  if @_expanded
    _(roll).delay 2000
    @_renderLogin()
  _renderLogin: (do_not_animate)->
    $loginBlk = @$el.find '.login-blk'
    spacer_height =
      if @_expanded
        $loginBlk.addClass 'after-story'
        6500
      else
        $loginBlk.removeClass 'after-story'
        1700
    css = 'margin-top': @zoomPx spacer_height
    parent_css = height: @zoomPx SCENE_HEIGHT - 6500 + spacer_height
    unless do_not_animate
      $loginBlk.animate css, EXPAND_DURATION
      @parent.$el.animate parent_css, EXPAND_DURATION
    else
      $loginBlk.css css
      @parent.$el.css parent_css


class Scene

  constructor: ->
    @layers = []
    @$el = $('#intro')

  updateLayout: ->
    width = $(window).width()
    scene =
      if width > SCENE_WIDTH
        width: SCENE_WIDTH
        left: (width - SCENE_WIDTH)/2
      else
        width: width
        left: 0

    zoom = scene.width / SCENE_WIDTH

    @$el.css 'font-size': zoomPx(18, zoom)

    @$el.find('.layers').css scene

    _(@layers).each (layer)->
      layer.resize zoom

  goAnimate: ->

    @$el.addClass 'animated'

    @layers = {
      bg: new BackgroundLayer 'bg-layer'
      events: new EventsLayer 'events-layer'
      story: new StoryLayer 'story-layer'
      snap: new SnapLayer 'snap-layer'
      func: new FuncLayer 'func-layer', @
    }

    updateScene = =>
      _(@layers).each (layer)->
        realTop = $(window).scrollTop()
        layer.scroll realTop

    updateBoth = =>
      @updateLayout()
      updateScene()

    updateBoth()

    renderLayers = =>
      _(@layers).each (layer)-> layer.render()
      _(renderLayers).delay 64
    renderLayers()

    $(window).on 'resize', _(updateBoth).throttle 198
    $(window).on 'scroll', _(updateScene).throttle 32


  goStatic: ->

    @layers = [
      new BackgroundLayer 'bg-layer'
      new StoryLayer 'story-layer'
      new SnapLayer 'snap-layer'
      new FuncLayer 'func-layer', @
    ]

    $(window).on 'resize', _(updateLayout).throttle 198

window.crushLand = ->
  scene = new Scene
  scene.goAnimate()
