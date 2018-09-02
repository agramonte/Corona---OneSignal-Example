local json = require "json"
local notifications

local N = {}
N.eventDispatcher = system.newEventDispatcher()

N.get_timezone = function()
	local now = os.time()
	return os.difftime(now, os.time(os.date("!*t", now)))
  end
 
N.get_tzoffset = function(timezone)
	local h, m = math.modf(timezone / 3600)
	return string.format("%+.4d", 100 * h + 60 * m)
end

N.networkListener = function(event) 
    N.eventDispatcher:dispatchEvent( { name="notify", type=event.type, data=event} )
end

N.notificationListener = function( event )
    N.eventDispatcher:dispatchEvent( { name="notify", type=event.type, data=event} )
end


N.registerDevice = function(appId, language, sessions)

    if system.getInfo("environment") == "simulator" then
        N.eventDispatcher:dispatchEvent( { name="notify", type="error", data="Not supported on simulator"} )
        return
    end

    --Device type
    local device_type = 1

    if system.getInfo("platform") == "iOS" then
        device_type = 0
    end

    --Time zone offset in seconds
    local offsetInSeconds = (N.get_tzoffset(N.get_timezone())/100) * 3600

    local requestBody = {}
    requestBody.app_id = appId 
    requestBody.device_type = device_type
    requestBody.identifier = notifications.getDeviceToken()
    requestBody.language = language
    requestBody.timezone = offsetInSeconds
    requestBody.game_version = system.getInfo("appVersionString")
    requestBody.device_os =  system.getInfo("platformVersion")
    requestBody.ad_id = system.getInfo("deviceID")
    requestBody.device_model = system.getInfo("architectureInfo")
    requestBody.session_count = sessions

    local url = "https://onesignal.com/api/v1/players"

    local headers = {}
    headers["Content-Type"] = "application/json"

    local params = {}
    params.body = json.encode (requestBody)
    params.headers = headers
        
    network.request( url, "POST", N.networkListener, params )
end

N.init = function(listerner, options)
    notifications = require( "plugin.notifications.v2" )

    N.eventDispatcher:addEventListener("notify", listerner)
    N.registerDevice(options.appId, options.language, options.sessions)

    Runtime:addEventListener( "notification", N.notificationListener )
end

return N