local json = require "json"
local notifications
local deviceType = 1
local deviceToken
local requestBody = {}
local options = {}

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

    if event.type == "remoteRegistration"  then
        
        deviceToken = event.token
        N.registerDevice(options.appId, options.language, options.sessions)
    else
        N.eventDispatcher:dispatchEvent( { name="notify", type=event.type, data=event} )
    end
end

N.isError = function(appId)

    local isError = false
    local errorString = ""

    if system.getInfo("environment") == "simulator" then
        errorString = errorString.."Not supported on simulator. "
        isError = true
    end

    if appId == nil then
        errorString = errorString.."App Id cannot be nil. "
        isError = true
        return
    end

    if deviceToken == nil then
        errorString = errorString.."Device token cannot be nil."
        isError = true
        return
    end

    if isError == true then
        N.eventDispatcher:dispatchEvent( { name="notify", type="error", data=errorString} )
    end

    return isError
end

N.registerDevice = function(appId, language, sessions)

    if N.isError(appId) == true then
        return
    end

    --Time zone offset in seconds
    local offsetInSeconds = (N.get_tzoffset(N.get_timezone())/100) * 3600

    requestBody.app_id = appId 
    requestBody.device_type = deviceType
    requestBody.identifier = deviceToken
    requestBody.language = language
    requestBody.timezone = offsetInSeconds
    requestBody.game_version = system.getInfo("appVersionString")
    requestBody.device_os =  system.getInfo("platformVersion")
    requestBody.ad_id = system.getInfo("deviceID")
    requestBody.device_model = system.getInfo("model")
    requestBody.session_count = sessions

    local url = "https://onesignal.com/api/v1/players"

    local headers = {}
    headers["Content-Type"] = "application/json"

    local params = {}
    params.body = json.encode (requestBody)
    params.headers = headers
        
    network.request( url, "POST", N.networkListener, params )
end

N.init = function(listerner, opts)
    notifications = require( "plugin.notifications.v2" )

   
    --Add listerner
    N.eventDispatcher:addEventListener("notify", listerner)

    --Save options
    options = opts

    Runtime:addEventListener( "notification", N.notificationListener )

    if system.getInfo("platform") == "ios" then
        deviceType = 0
        notifications.registerForPushNotifications()
    
    else
        deviceToken = notifications.getDeviceToken()
        N.registerDevice(options.appId, options.language, options.sessions)
    end 

end

N.isDevBuild = function()
    requestBody.test_type = 1
end

return N
