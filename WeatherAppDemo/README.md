#  Weather Demo App

- Follows MVVM architecture with good old GCD API at service level
- Try to leverage pub-sub bindings for viewmodel to view from Combine


##Limitations:
- Due to API limit, providing city auto complete via local list (not using geo direct for fetching cities list)

- Didn't handle location authorization decline path - in full
- If we have cached data on disk, that location won't be refreshed unless full detail screen in opened

## TODO
- Use OSLog for adding debug logs
- Use Coordinator based navigation architecture
- Create NavigationController in code instead fo storyboard to silence below assert in console.
    self.window?.rootViewController = navigationVC self.window?.makeKeyAndVisible() //https://developer.apple.com/forums/thread/714278

