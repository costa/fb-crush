window.flash_notice = (message_html)->
  flash 'notice', message_html
window.flash_error = (message_html)->
  flash 'error', message_html
window.flash_alert = (message_html)->
  flash 'alert', message_html


flash = (flash_type, message_html)->
  $('#flash').prepend JST['flash']
    alert_class:
      switch flash_type
        when 'success'
          'alert-success' # Green
        when 'error'
          'alert-danger' # Red
        when 'alert'
          'alert-warning' # Yellow
        when 'notice'
          'alert-info' # Blue
    message_html: message_html
