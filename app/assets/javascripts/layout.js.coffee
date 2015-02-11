$ ->
  $(  # http://www.google.com/fonts#UsePlace:use
    "<link href='http://fonts.googleapis.com/css?family=Droid+Sans:400,700' rel='stylesheet'>"
  ).appendTo('head:first').on 'load', ->
    $('body:first').css(
      'font-family': 'Droid Sans, sans-serif'
    )
