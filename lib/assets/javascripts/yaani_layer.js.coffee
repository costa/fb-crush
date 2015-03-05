class Layer
  background_props: ['image', 'position', 'repeat']

  constructor: (layer_class)->
    # NOTE copy props from CSS
    $sample = $('<div>').appendTo($('body')).addClass(layer_class)
    @_background = {}
    _(@background_props).each (prop)=>
      @_background[prop] = $sample.css("background-#{prop}")
    $sample.remove()
    @_top_offset = parseInt(@_background.position.split(' ')[1])
  zoomWith: (zoomer)->
    @_zoomer = zoomer
    @_render()
  _render: ->
    @background = _(@_background).clone()
    @background.position = "0 #{@_zoomer.zoomPx(@_topOffset())}"
  _topOffset: ->
    @_top_offset

class ScrollableLayer extends Layer
  scroll_ratio: 1

  constructor: ->
    super
    @_top = 0
  _topOffset: ->
    super - @_top
  scroll: (top)->
    @_top = @scroll_ratio * top
    @_render()

class ScrollableAppearableLayer extends ScrollableLayer
  constructor: ->
    super
    @setToShow()

  setToShow: ->
    _(@).extend
      appear_top: -999
      disappear_top: 999999
  setToHide: ->
    _(@).extend
      appear_top: 0
      disappear_top: 0

  _render: ->
    if @_top > @appear_top && @_top < @disappear_top
      super
    else
      @background = null

class @YaaniLayer
  Scrollable: ScrollableLayer
  ScrollableAppearable: ScrollableAppearableLayer

window.$animateScrollDocumentTo = (top, duration=900)->  # XXX
  if duration
    $('html, body').animate {scrollTop: top}, duration
  else
    $(document).scrollTop top
