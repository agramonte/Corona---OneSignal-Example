--
--- For this sample to work you need to:
--- 1. copy and past your *.json google services file from Firebase console into the root of this project.
--- 2. find your appId and replace the blank appId with yours from oneSignal
---
local launchArgs = ...

local json = require "json"
local notify = require( "notification" )
local grid = require( "grid" )

local gridListerner = function(event)


end

local showNotification = function(title, message)

    local tableGridOptions = {
        --Entire Grid
        gridWidth = .80, -- As percentage of full width.
        gridHeight = .70, -- As percentage of full height.
        backgroundColor = { 0, 0.4, 0.4, 0},
 
        --Title name.
        showTitle = true,
        titleName = title,

        --Header
        columnWidthPercent = {1.00},
        headerHeight = 150,
        headerMultiLine = true,
        columnDisplayName = {message},
        showColumnHeader = true,
    
        --Columns row
        rowDataRoot = "data",
        columnDataName = {"None"}
    }
      

    grid.DisplayGrid(nil, tableGridOptions, gridListerner)

end

local setNotificationValues = function(notification)
    local title

    if notification.androidPayload ~= nil then
        title = notification.androidPayload.title

    else
       title = notification.iosPayload.title

    end

    showNotification(title, notification.alert)

end

if ( launchArgs and launchArgs.notification ) then

    print("Resposne: ", json.prettify(launchArgs.notification))
    setNotificationValues(launchArgs.notification)
end

local notifyListerner = function(event) 
    print("Resposne: ", json.prettify(event))

    if event.type ~= "remote" then
        return
    end

    setNotificationValues(event.data)
end

local onSystemEvent = function( event ) 
    
    if ( event.type == "applicationStart" ) then

        notify.isDevBuild() -- remove for prod builds.
        notify.init(notifyListerner, {
            appId = "", -- AppId from One Signal
            language = "en", -- Language. I use the candlelight plugin to get this, but you can also use "os.*" library.
            sessions = 23 -- I grab this from gamespark in my game but you can use a local variable you increment for every time they launch the app.
            }
        ) 
    end
    
    return true
end


Runtime:addEventListener( "system", onSystemEvent )
