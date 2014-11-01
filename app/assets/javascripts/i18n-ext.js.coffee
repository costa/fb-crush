#= require i18n

# XXX experiment

I18n._boring_translate = I18n.translate
I18n.t = I18n.translate = (scope, options)->
  if typeof scope == 'string' && scope[0] == '.'
    scope = scope.slice 1
    options ||= {}
    options.scope ||= I18n._local_scope
  I18n._boring_translate scope, options

I18n.localScope = (scope, block)->
  upper_scope = @_local_scope
  @_local_scope = scope
  block()
  @_local_scope = upper_scope
