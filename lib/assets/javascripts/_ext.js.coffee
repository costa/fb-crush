window._pickValues = (obj, keys...)->
  _(keys).map (key)-> obj[key]

jQuery.fn.reverse = [].reverse;
