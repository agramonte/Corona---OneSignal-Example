local widget = require( "widget" )
local _W = display.contentWidth
local _H = display.contentHeight
local mF = math.floor 

local L = {}
--L.tableView = nil
L.originalData = {}
L.modifiedData = {}


-- Variables changed by the code
local rowStartingYPosition = display.contentHeight/16
local rowHeight = display.contentHeight * .05
local fontSize = 20
local headerFontSize = 50
local fontName = native.systemFont



L.createTableData = function(entry, options)
    local params = {}
    for i, columns in ipairs(options.columnDataName) do
        print("Column Data:", entry[options.columnDataName[i]])
        params[i] = entry[options.columnDataName[i]]
    end

    return params
end

L.createCircle = function(width)
    local closeCircleGrp = display.newGroup()

    local closeCircle = display.newCircle( 0, 0, width)
    closeCircle:setFillColor( 0, 0, 0)

    local closeCircleLine1 = display.newLine(closeCircle.x - closeCircle.contentWidth/4, closeCircle.y - closeCircle.width/4, closeCircle.x + closeCircle.contentWidth/4, closeCircle.y + closeCircle.width/4)
    closeCircleLine1.strokeWidth = 3
    closeCircleLine1:setStrokeColor(1)

    local closeCircleLine2 = display.newLine(closeCircle.x - closeCircle.contentWidth/4, closeCircle.y + closeCircle.width/4, closeCircle.x + closeCircle.contentWidth/4, closeCircle.y - closeCircle.width/4)
    closeCircleLine2.strokeWidth = 3
    closeCircleLine2:setStrokeColor(1)
    
    closeCircleGrp:insert(closeCircle)
    closeCircleGrp:insert(closeCircleLine1)
    closeCircleGrp:insert(closeCircleLine2)
    closeCircleGrp.closeCircle = closeCircle

    return closeCircleGrp
end


L.onRowRender = function(event)
    --Set up the localized variables to be passed via the event table
    local row = event.row
    local id = row.index

    if event.row.params ~= nil and event.row.params.headerName ~= nil and id == 1 then

            local params = event.row.params
            
            local hdrTxt = (params.headerName or "header")
            local headerTxt = display.newText( hdrTxt, row.contentWidth/2, row.contentHeight/2, fontName, fontSize )
            headerTxt:setFillColor( 0 )
            row:insert(headerTxt)

            local closeCircleGrp = params.closeCircle
            closeCircleGrp.x = row.contentWidth - row.contentHeight/2
            closeCircleGrp.y = row.contentHeight/2         
            row:insert(closeCircleGrp)

            --closeCircle:addEventListener( "touch",  L.tableView.onCloseTouched )
    else
        
        if  event.row.params ~= nil then

            local params = event.row.params
            local columnData = params.columnData
            local columnWidthPercent = params.columnWidthPercent

            local totalWidth = 0

            for i, column in ipairs(columnData) do
                local columnBox = display.newRect( totalWidth, row.contentHeight/2, row.contentWidth * columnWidthPercent[i], row.contentHeight * .98)
                columnBox.strokeWidth = 2
                columnBox:setStrokeColor(1, 1, 1, 0)
                columnBox.anchorX = 0
                columnBox:setFillColor( .4, .4, .4, 1 )
                row:insert(columnBox)

                local clmTxt = (columnData[i] or "NA")

                if event.row.params.headerMultiLine == true then
                    local columnText = display.newText( clmTxt, columnBox.x + columnBox.contentWidth/2, columnBox.y, row.width * .90, row.height * .90, fontName, fontSize )
                    row:insert(columnText)  
                else
                    local columnText = display.newText( clmTxt, columnBox.x + columnBox.contentWidth/2, columnBox.y, fontName, fontSize )
                    row:insert(columnText)  
                end

                totalWidth = totalWidth + columnBox.contentWidth
            end
            
        end
    end

end

L.onRowTouch = function(event)

end

L.scrollListener = function(event)

end


L.AdjustSize = function()
    rowStartingYPosition = display.contentHeight/10
    rowHeight = display.contentHeight * .10

end

L.DisplayGrid = function(table, options, listerner)
    local tableView = nil
    
    if _W > _H then
        L.AdjustSize()
    end

    local backgroundColor = {0.2, 0.2, 0.2}

    if options.backgroundColor ~= nil then
        backgroundColor = { (options.backgroundColor[1] or 0.4), (options.backgroundColor[2] or 0.4), (options.backgroundColor[3] or 0.4), (options.backgroundColor[4] or 0.5)}
    end

    local headerColor =  { default={.5,.5,.5}, over={.5,.5,.5} }

    if options.headerColor ~= nil then
        headerColor = { default={ (options.headerColor[1] or .5),(options.headerColor[2] or .5),(options.headerColor[3] or .5)}, over={(options.headerColor[1] or .5),(options.headerColor[2] or .5),(options.headerColor[3] or .5)} }
    end

    local titleColor =  { default={.5,.5,.5}, over={.5,.5,.5} }

    if options.titleColor ~= nil then
        headerColor = { default={ (options.titleColor[1] or .5),(options.titleColor[2] or .5),(options.titleColor[3] or .5)}, over={(options.titleColor[1] or .5),(options.titleColor[2] or .5),(options.titleColor[3] or .5)} }
    end

    tableView = widget.newTableView(
        {
            x = (options.x or display.contentWidth/2),
            y = (options.y or display.contentHeight/2),
            height = display.contentHeight * (options.gridHeight or .70),
            width = display.contentWidth * (options.gridWidth or .80),
            noLines = (options.noLines or true),
            backgroundColor = backgroundColor,
            onRowRender = L.onRowRender,
            onRowTouch = L.onRowTouch,
            listener = L.scrollListener
        }
    )

    tableView.eventDispatcher = system.newEventDispatcher()
    tableView.eventDispatcher:addEventListener("grid", listerner)

    tableView.onCloseTouched = function(event)
        if not (event.phase == "began") then
            return
        end
        
        tableView = tableView:removeSelf()
        tableView = nil

        --print("++++++garbage:",math.floor(collectgarbage('count')))
        
    end

    if options.showTitle == true then
        print("Options TitleHeight:", options.titleHeight)

        local width = ((options.titleHeight or rowHeight) * .70)/2
        local closeCircleGrp = L.createCircle(width)
        closeCircleGrp:addEventListener( "touch",  tableView.onCloseTouched )

        tableView:insertRow {
            rowHeight = (options.titleHeight or rowHeight),
            isCategory = (options.isCategory or false),
            rowColor = titleColor,
            params = {
                headerName = (options.titleName or ""),
                closeCircle = closeCircleGrp
            }
        }
    end

    if options.showColumnHeader == true then

        tableView:insertRow {
            rowHeight = (options.headerHeight or rowHeight),
            isCategory = (options.isCategory or true),
            rowColor = headerColor,
            params = {  
                columnData = options.columnDisplayName,
                columnWidthPercent = options.columnWidthPercent,
                headerMultiLine = (options.headerMultiLine or false)
            }
        }
    end

    if table ~= nil then
        for i, entry in pairs(table) do
            local userName = entry.userName


            print("row:", i)

            tableView:insertRow {  
                rowHeight = (options.rowHeight or rowHeight),
                isCategory = false,
                rowColor = headerColor,
                params = {
                    columnData = L.createTableData(entry, options),
                    columnWidthPercent = options.columnWidthPercent
                }
            }
        end
    end

    

    return tableView
end

L.init = function()
    
end


return L
