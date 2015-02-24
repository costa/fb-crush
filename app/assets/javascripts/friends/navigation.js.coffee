class FriendsApp::Navigation extends Backbone.View

  initialize: (options)->
    super
    @list_view = options.list_view
    @$search_form = @$el.find('form.search')
    @$search_inp = @$search_form.find('input')
    @$search_clr = @$search_form.find('.clear-btn')
    @$title = @$el.find('.navbar-brand')
    @_throttled_onAdd = _(@_updateStats).throttle 1500, leading: false
    @_bound_triggerFilter = => @_triggerFilter()
    @_bound_clearFilter = => @_clearFilter()
    @_clearFilter()

  render: ->
    super
    @listenTo @list_view, 'insert', @_throttled_onAdd  # NOTE the event callback params are ignored
    @_throttled_onAdd()
    @$search_inp.on 'input', @_bound_triggerFilter
    @$search_clr.on 'click', @_bound_clearFilter
    @

  remove: ->
    @$search_inp.off 'input', @_bound_triggerFilter
    @$search_clr.off 'click', @_bound_clearFilter

  _updateStats: ->
    @$title.
      animate(opacity: 0.1, 600).
      queue((next)=>
        @$title.html I18n.t('title_html', count: _(@list_view.kids).size(), scope: 'friends.navigation')
        next()
        ).
      animate(opacity: 1, 600)

  _triggerFilter: ->
    val = @$search_inp.val()
    @$search_clr.toggleClass 'disabled', !val
    @list_view.trigger 'filter', val

  _clearFilter: ->
    @$search_inp.val ''
    @_triggerFilter()
