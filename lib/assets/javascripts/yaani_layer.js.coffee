class Layer extends Backbone.View
  zoomWith: (zoomer)->
    @_zoomer = zoomer
    @render()
  render: ->
    @$el.css top: @_zoomer.zoomPx @_topOffset()
    @
  _topOffset: ->
    @_top_offset ||= _(parseInt(@$el.css('background-position').split(' ')[1])).tap =>
      @$el.css 'background-position', '0 0'

class ScrollableLayer extends Layer
  initialize: (options)->
    super
    @scrollRatio = options.scrollRatio || 1
    @_top = 0
  _topOffset: ->
    super - @_top
  scroll: (top)->
    @_top = @scrollRatio * top
    @render()

class ScrollableAppearableLayer extends ScrollableLayer
  initialize: ->
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

  render: ->
    if @_top > @appear_top && @_top < @disappear_top
      super
      @$el.show()
    else
      @$el.hide()
    @

class @YaaniLayer
  Scrollable: ScrollableLayer
  ScrollableAppearable: ScrollableAppearableLayer

window.$animateScrollDocumentTo = (top, duration=900)->  # XXX
  if duration
    $('html, body').animate {scrollTop: top}, duration
  else
    $(document).scrollTop top
