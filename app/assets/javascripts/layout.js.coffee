$ ->
  $(  # http://www.google.com/fonts#UsePlace:use
    "<link href='//fonts.googleapis.com/css?family=Noto+Sans:400,700,400italic' rel='stylesheet'>"
  ).appendTo('head:first').on 'load', ->
    $('body:first').css(
      'font-family': 'Noto Sans, sans-serif'
    )
