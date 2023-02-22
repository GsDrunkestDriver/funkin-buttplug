package meta;

import flixel.util.FlxTimer;

class ButtplugUtils
{
    //no, i'm not kidding.
    //This class simplifies the process of setting up and using the buttplug frontend.
    //It's not perfect at the minute as I wrote this literally yesterday, but it (sorta) works.
    //Needs a lot of tuning and testing, but it's a start.

    //USAGE (this assumes you've followed the funkin buttplug guide):
    //1. Put this class in your mod's source folder. (You might need to clean up at the top if you're not using forever)
    //2. Call ButtplugUtils.initialise() in Main a little after the game's been created.
    //3. Call ButtplugUtils.vibrate() when you want to vibrate the device. By default it should vibrate at 75% intensity for 0.075 seconds.
    //4. If you use this, make sure to credit me in your mod's credits.

    //Created by God's Drunkest Driver and originally used in the mod "Cracked Catastrophe".

    public static var _request:haxe.Http = new haxe.Http("http://localhost:6969/api/Device/List"); //this is the request to get the list of devices, basically check if the server is running
    public static var vibrateRequest:haxe.Http = new haxe.Http("http://localhost:6969/api/Device/Command");
    public static var stopRequest:haxe.Http = new haxe.Http("http://localhost:6969/api/Device/StopDeviceCmd");
    public static var payloadRequest:haxe.Http = new haxe.Http("http://localhost:6969/api/Device/Command");
    public static var device:String = "";
    public static var deviceEncoded:String = "";
    public static var isVibrating:Bool = false;
    public static var deviceConnected:Bool = true;
    public static var emergencyStopActive:Bool = false;
    /**
     * The amount of strength on the vibrations.
     */
    public static var intensity(default, set):Int;


    //TODO: look into setting up sequence payload based on the current song's bpm - requires a JSON encoded POST query.
    //TODO: figure out how the fuck to send the payload to the frontend. i can send post requests, but I don't know if I can access the request body.

    /**
     * Sets up the GET requests and the device you'll be '''using'''. Best place to call this is in Main a little after the game's been created.
     */
    public static function initialise()
    {
        _request.onData = function(data:String)
        {
            device = filterDevices(data);
            trace(data);
            if (device == "")
            {
                trace("no device found");
                deviceConnected = false;
                return;
            }
            trace("device:" + device);
            deviceEncoded = encodeDevice(device);
            trace("deviceEncoded:" + deviceEncoded);
            vibrateRequest.url = "http://localhost:6969/api/Device/VibrateCmd/" + deviceEncoded + '/$intensity'; //change the 75 to your desired intensity!
            stopRequest.url = "http://localhost:6969/api/Device/VibrateCmd/" + deviceEncoded + "/0"; //don't change this!
            payloadRequest.url = "http://localhost:6969/api/Device/SequenceVibrateCmd/" + deviceEncoded;
            deviceConnected = true;
        }
        _request.onError = function(error:String)
        {
            trace(error);
        }

        vibrateRequest.onData = function(data:String)
        {
            trace(data);
        }
        vibrateRequest.onError = function(error:String)
        {
            trace(error);
        }

        stopRequest.onData = function(data:String)
        {
            trace(data);
        }

        stopRequest.onError = function(error:String)
        {
            trace(error);
        }

        payloadRequest.onData = function(data:String)
        {
            trace(data);
        }

        payloadRequest.onError = function(error:String)
        {
            trace(error);
        }

        _request.addHeader("SecretKey", "CraCatButtplugSupport");
        vibrateRequest.addHeader("SecretKey", "CraCatButtplugSupport");
        stopRequest.addHeader("SecretKey", "CraCatButtplugSupport");
        payloadRequest.addHeader("SecretKey", "CraCatButtplugSupport");
        payloadRequest.addHeader("Content-Type", "application/json");


        _request.request();
    }

    /**
     * Takes the response from the server and filters it down to just the device name.
     * @param response The response from the server after a device list request.
     * @return The device name.
     */
    public static function filterDevices(response:String):String
    {
        //clean up the response from the server
        //and return only the device
        //an empty response looks like this: {"Devices":[],"Action":"List"}

        var device = "";

        //start off by getting rid of the first 12 characters
        //which is {"Devices":[
        response = response.substr(12);

        trace("filterDevices is working with:" + response);

        //now we need to trim off everything after the first ]
        //which is the end of the device list
        var end = response.indexOf("]");
        if (end != -1)
        {
            response = response.substr(0, end);
        }

        trace("filterDevices is working with:" + response);

        //now we need to trim off everything after the first ,
        //which is the end of the first device
        end = response.indexOf(",");
        if (end != -1)
        {
            response = response.substr(0, end);
        }

        trace("filterDevices is working with:" + response);

        //now we need to trim off the first "
        //which is the start of the device name
        response = response.substr(1);

        trace("filterDevices is working with:" + response);

        //now we need to trim off the last "
        //which is the end of the device name
        end = response.indexOf("\"");
        if (end != -1)
        {
            response = response.substr(0, end);
        }

        trace("filterDevices is returning:" + response);

        //and we're done!
        return response;

    }

    /**
     * Encodes the device name so it can be sent to the server.
     * @param dev The device name.
     * @return The encoded device name.
     */
    public static function encodeDevice(dev:String):String
    {
        //encode the device name so it can be sent to the server

        //we'll just do spaces for now, i'll add more if people complain that their buttplug is incompatible with a friday night funkin mod
        dev = dev.split(" ").join("%20");

        trace("encodeDevice is returning:" + dev);

        return dev;

    }

    /**
     * Sends a vibrate command to the server.
     * @param duration the amount of milliseconds the vibration is going to prolong. 
     * **WARNING:** The duration will be set to 50 if it's lower than that number due to frontend requirements. 
     */
    public static function vibrate(duration:Float = 75)
    {
        if (duration < 50)
            duration = 50;
        //send a vibrate command to the server
        //it'll vibrate the device at 25% for 0.05 seconds (i'd set it lower but the frontend doesn't go lower than 50ms)
        //then stop the device
        if (isVibrating == false && deviceConnected == true && emergencyStopActive == false)
        {
            isVibrating = true;
            vibrateRequest.request();
            new FlxTimer().start(duration * 0.001, function(timer:FlxTimer) //stops the device after 0.075 seconds via a stop request
            {
                stopRequest.request();
                isVibrating = false;
            });
        }

    }

    /**
     * Re-requests the device list from the server. Useful for testing, mostly.
     */
    public static function refreshDevices()
    {
        //refresh the device list
        _request.request();
    }

    /**
     * Creates a JSON encoded payload for the device to vibrate to the beat of the song.
     * @param crochet The crochet (length of a beat) of the song.
     * @return The JSON encoded payload.
     */
    public static function createPayload(crochet:Float):String
    {
        //creates a payload for the device to vibrate to the beat of the song
        //essentially it grabs the current song's crochet (length of a beat) and then creates a payload based on that
        //if all goes well, it should vibrate for half a beat, then stop for half a beat. It'll loop until a request is sent to stop it.
        //it'll need to be sent to the server as a JSON encoded POST query too, which won't be fun to do when i don't know how to do that.

        //start off by turning the crochet into an int
        var crochetInt = Std.int(crochet / 2);

        //now we need to turn that into a string
        var crochetString = Std.string(crochetInt);

        //now we need to build the json payload
        var jsonPayload = '
        {
            "Loop":true,
            "Time":[${crochetString}, ${crochetString}],
            "Speeds":[
                [50, 0]
            ]

        }';

        //and we're done!
        return jsonPayload;

    }

    /**
     * Sends a payload to the server.
     * @param payload The payload to send to the server. Must be JSON encoded.
     */
    public static function sendPayload(payload:String)
    {
        //sends the payload to the server via a POST query
        if (deviceConnected == true)
        {
            trace("sending payload: " + payload);
            trace("to this url: " + payloadRequest.url);
            payloadRequest.setPostData(payload); //god i hope this works
            payloadRequest.request(true); //true means it's a POST query
        }
        else
        {
            trace("device not connected, not sending payload");
        }
    }

    /**
     * Sends a stop command to the server.
     * @param emergency Prevents vibration from being called again. Defaults to false.
     */
    public static function stop(?emergency:Bool = false)
    {
        //sends a stop command to the server
        //it'll stop the device from vibrating
        stopRequest.request();
        if (emergency == true)
            emergencyStopActive = true;
    }
    static function set_intensity(value:Int)
    {
        intensity = value;
        vibrateRequest.url = "http://localhost:6969/api/Device/VibrateCmd/" + deviceEncoded + '/$intensity';
        return value;
    }
}
