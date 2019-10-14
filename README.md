# Trams

This is a trams resource for FiveM. Instead of spawning the trains itself it will use SetRandomTrains(1) and let the game take care of it. To enable this in FiveM you need to call an extra native which was found by @Disquse.

This resource will also take care of the doors. When the train is driving the doors are closed and at a station the non-corresponding doors will still be closed. Like in GTA IV it will also show you the next upcoming station.

![image](https://user-images.githubusercontent.com/15322107/64922914-cafb0d80-d7d4-11e9-908f-9ae45e53496a.png)

## Translating

There's a config.lua where you can easily change the "next station is" text, but please make sure you read the comments above first. If you want to translate the station names open client.lua where you willl find a big table with every station name.
