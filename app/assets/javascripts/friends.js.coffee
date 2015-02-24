class @FriendsApp
  run: (friends_url, pusher_or_key, channel)->

    # models
    @friends = new @Friends [], url: friends_url  # NOTE in the namespace for debugging
    pusher_async pusher_or_key, (pusher)=>
      pusher.connection.bind 'connected', => @friends.fetch()
      @_friendsBackpusher = new Backpusher pusher.subscribe(channel), @friends

    # views
    new FriendsApp::ListView(collection: @friends, el: '#friends').render()
    new FriendsApp::Navigation(collection: @friends, el: '#window-title').render()
