#= require i18n

# XXX experiment

I18n._boring_translate = I18n.translate
I18n.t = I18n.translate = (scope, options)->
  scope = I18n.localScope + scope  if typeof scope == 'string' && scope[0] == '.'
  I18n._boring_translate scope, options
