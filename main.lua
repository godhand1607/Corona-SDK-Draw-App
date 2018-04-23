-- MAIN.LUA
_W = display.contentWidth
_H = display.contentHeight

local bg = display.newRect( _W, _H, _W, _H )
bg.x = _W * 0.5
bg.y = _H * 0.5
bg:setFillColor( 1, 1, 1, 0 )

function getRandomColor()
    return {
        math.random( 1, 255 ) / 255,
        math.random( 1, 255 ) / 255,
        math.random( 1, 255 ) / 255,
        1
    }
end

function getRandomWidth()
    return math.random( 1, 9 )
end

local widget = require( "widget" )
local drawingGroup = require( "lib.canvas" ):new({
    lineColor = getRandomColor(),
    lineWidth = getRandomWidth(),
    width = _W, -- width of the drawing canvas
    height = _H, -- height of the drawing canvas
})
drawingGroup.x = _W * 0.5
drawingGroup.y = _H * 0.5


-----------------------------------
-- UNDO & Change Color FUNCTIONS (not required)
-----------------------------------

function changeColor()
    drawingGroup.changeColor(getRandomColor())
end

function changeWidth()
    drawingGroup.changeWidth(getRandomWidth())
end

function erase()
    drawingGroup.cleanDraw()
end

function save()
    drawingGroup.saveAsImage( "image.png" )
end


-----------------------------------
-- UNDO & ERASE BUTTONS (not required)
-----------------------------------

local colorButton = widget.newButton{
    left = display.contentWidth - 305,
    top = display.contentHeight - 75,
    label = "Change Color",
    width = 100, height = 28,
    cornerRadius = 8,
    onRelease = changeColor
}

local widthButton = widget.newButton{
    left = display.contentWidth - 125,
    top = display.contentHeight - 75,
    label = "Change Width",
    width = 100, height = 28,
    cornerRadius = 8,
    onRelease = changeWidth
}

local clearButton = widget.newButton{
    left = display.contentWidth - 305,
    top = display.contentHeight - 45,
    label = "Clear",
    width = 100, height = 28,
    cornerRadius = 8,
    onRelease = erase
}

local saveButton = widget.newButton{
    left = display.contentWidth - 125,
    top = display.contentHeight - 45,
    label = "Save Image",
    width = 100, height = 28,
    cornerRadius = 8,
    onRelease = save
}
