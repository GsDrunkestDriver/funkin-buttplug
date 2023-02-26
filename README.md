# Funkin' Buttplug

This repo contains the funkin-side source code for implementing beat-based buttplug support.
This implementation requires a couple programs in order to work, but it's pretty easy to set up.

Check out an example of the implementation [here!](https://github.com/GsDrunkestDriver/funkin-buttplug-example-repo)

***

## DISCLAIMER

This is a very rough implementation. There's a lot of things that will go wrong, and as of now ***I wouldn't recommend using this on something you're going to shove up your ass.***



***

## Dependencies

* [ToyWebBridge](https://github.com/kyrahabattoir/ToyWebBridge)
* [Intiface Central](https://intiface.com/central/)

***

## Setup

1. Install the dependencies. (this includes running through intiface central's in-program setup)

2. Replace ToyWebBridge's start.bat and appsettings.json with the ones in this repo. (this changes the port ToyWebBridge runs on to 6969 and sets the secret key)

3. Place ButtplugUtils.hx somewhere in your project's source folder.

4. Call ButtplugUtils.initialise() somewhere near the start of the program. (For example, I call it in Init.hx in the forever project this was made for)

5. You're all set! You can now use the functions listed below to control your toys.

***

## Functions

### ButtplugUtils.initialise()

Initialises the buttplug client. This should be called before any other functions.

### ButtplugUtils.vibrate(duration:Float = 75)

Vibrates the connected toy at `intensity`% power for `duration`ms. This can be easily modified to take in different values based on your needs.

### ButtplugUtils.stop(?emergency:Bool = false)

Stops the connected toy. If emergency is true, the toy will stop and vibration will be disabled until the next time the program starts up.

### ButtplugUtils.createPayload(crochet:Float, ?loop:Bool = false)

Generates a vibration pattern payload based on the supplied crochet value to vibrate on beat.
Due to the way the frontend handles payloads, it's advisable to generate a non-looping payload and call ButtplugUtils.sendPayload() every beatHit().
Returns a JSON-encoded string that can be passed to ButtplugUtils.sendPayload().

### ButtplugUtils.sendPayload(payload:String)

Sends the supplied payload to ToyWebBridge via a JSON-encoded POST request.
If your payload doesn't loop, you'll need to call this every beatHit().
If your payload loops, don't forget to call ButtplugUtils.stop() at the end of the song!

### ButtplugUtils.set_intensity(value:Int)

Sets the intensity of ButtplugUtils.vibrate() and ButtplugUtils.createPayload() to your chosen value.
Values under 0 will be rounded up to 0, and values over 100 will be rounded down to 100 as the intensity is a percentage.

### ButtplugUtils.checkDependencies()

Checks if ToyWebBridge and Intiface Central are running. Returns true if both are running, false if either is not.
If this returns false, most functions will be disabled. This isn't meant to be called by the user, but it's there if you want to use it for whatever reason.

***

## Tips

* It's advisable to use payloads instead of calling ButtplugUtils.vibrate() every beatHit, as the server will rely on stop commands from your mod to stop the vibration 
which can lead to some undesirable behaviours if there's a lag spike or something.

* You can use an xbox controller to test this! It'll get picked up by Intiface Central and handles the vibration commands just fine.

* More to come, probably.
