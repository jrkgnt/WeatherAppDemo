#  Weather Demo App

- Follows MVVM architecture with good old GCD API at service level
- Use of size class for rendering 2 cells on ipad vs 1 cell on iphone
- Caches the images as per requirements
- Used pub-sub bindings for viewmodel to View controller using Combine. 
    Note: This is not standard approach where view properties are  directly binded to properties in viewmodel. Here i the view is passed the entire viewmodel (this is unnecessary and only needed properties need to be sent). 


## Limitations:
- No capability to delete cities once added. Need to delete app. [Not in requirements but thought would be helpful functionality]
- Due to API limit, providing city auto complete via MapKit API MKLocalSearchCompleter (not using geo direct for fetching cities list)

- Weather data on the list is from cached data on disk, location's weather detail won't be refreshed unless full detail screen in opened.

- Duplicate cells in list is possible if you search & add same city as current location (since lat/long retunred via CLLocation manager & weather api reponse are different in deicmals and accuracy can't be attained even by rounding to 4 decimals)

## TODO

- Use Coordinator based navigation architecture
- Create NavigationController in code instead fo storyboard to silence below assert in console.
    self.window?.rootViewController = navigationVC self.window?.makeKeyAndVisible() //https://developer.apple.com/forums/thread/714278

