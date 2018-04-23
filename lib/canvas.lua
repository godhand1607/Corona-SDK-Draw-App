---------------
-- Code By Paulo Peres Jr
-- For NuOffer Starting Date Jun 27 2014
---------------
-- Starting
-- local drawing = require("drawing"):new({
--      Color = {0.5,0.5,0.5,0.5}, -- Array of the colors you want
--      width = display.contentWidth, -- width of the drawing canvas
--      height = display.contentHeight, -- height of th drawing canvas
--  });
-- drawing.x = _W*0.5;
-- drawing.y = _H*0.5;
-- Methods
-- drawing.cleanDraw();
-- Clean all the Drawing Made;
-- drawing.changeColor({0.5,0.5,0.5,0.5});
-- chaning the color of the next drawing
-- drawing.clean()
-- Remove all the drawing and the drawing functionalities, cleaning the sage
-- drawing.saveAsImage(imageName)
-- Save the drawing as image on the systemDocumentsDirectory


require( "lib.vector2d" )

local d = {}

function d:new( options )
    -- Parameters
    local width = options.width or display.contentWidth
    local height = options.height or display.contentHeight
    local lineColor = options.lineColor
    local lineWidth = options.lineWidth or 1

    -- Necessary Variables
    local canvasContainer = display.newGroup()
    local canvas = display.newRect( 0, 0, width, height )
    local canvasGroup = display.newGroup()
    canvasContainer:insert( canvas )
    canvas.x = 0
    canvas.y = 0

    local mathTools = {
        min = math.min,
        max = math.max,
        floor = math.floor,
        pow = math.pow,
    }

    local points = {}
    local velocities = {}

    local connectingLine = false
    local finishingLine = false

    local prevValue = 0
    local curValue = 0
    local prevC
    local prevD
    local prevG
    local prevI

    -- INTERPOLATION OF THE SMOOTH LINES
    local min = 5
    local max = 10

    -- PEN
    local pen = {
        minWidth = lineWidth,
        maxWidth = lineWidth + 1,
        overdraw = 1, -- Size of the overdraw to do anti-aliasing,
        fill = {
            type = "image",
            filename = "pen_pattern.png",
        }
    }

    local dMinX = nil
    local dMaxX = nil
    local dMinY = nil
    local dMaxY = nil

    function createDrawBoundaries( xMax, xMin, yMax, yMin )
        -- Creating a rectangle with the bounderies of the draw
        local Q1 = Vector2D:new( xMin,yMax )
        local Q2 = Vector2D:new( xMin, yMin )
        local Q3 = Vector2D:new( xMax, yMax )
        local Q4 = Vector2D:new( xMax, yMin )

        local star = display.newLine( Q1.x, Q1.y, Q3.x, Q3.y )
        star:append( Q4.x, Q4.y, Q2.x, Q2.y, Q1.x, Q1.y )
        star:setStrokeColor( 0, 0, 0, 0 )
        star.strokeWidth = 1

        canvasGroup:insert( star )

        -- Finding the equation of the line
        local m1 = (Q4.y - Q1.y) / (Q4.x - Q1.x)
        local m2 = (Q3.y - Q2.y) / (Q3.x - Q2.x)
        local b1 =  Q1.y - (m1 * Q1.x)
        local b2 =  Q2.y - (m2 * Q2.x)
        local x = (b2 - b1) / (m1 - m2)
        local y = m1 * x + b1

        -- Returning the center;
        return Vector2D:new( x, y )
    end

    function ADD_CIRCLE( vec, rotation )
        local circle = display.newCircle(
            vec.x,
            vec.y,
            vec.width * 0.5 + pen.overdraw * 0.5
        )
        circle.fill = pen.fill
        circle.fill.rotation = rotation
        circle:setFillColor(
            lineColor[1],
            lineColor[2],
            lineColor[3],
            lineColor[4]
        )
        canvasGroup:insert( circle )
    end

    function getRectMin( A, B, C, D, axis )
        return mathTools.min(
            A[axis],
            mathTools.min(
                B[axis],
                mathTools.min(
                    C[axis],
                    D[axis]
                )
            )
        )
    end

    function getRectMax( A, B, C, D, axis )
        return mathTools.max(
            A[axis],
            mathTools.max(
                B[axis],
                mathTools.max(
                    C[axis],
                    D[axis]
                )
            )
        )
    end

    function ADD_RETANGLE( A, B, C, D, cur, val, rotation )
        -- Finding the positions of the Rectangle
        local minY = getRectMin( A, B, C, D, "y" )
        local maxY = getRectMax( A, B, C, D, "y" )
        local minX = getRectMin( A, B, C, D, "x" )
        local maxX = getRectMax( A, B, C, D, "x" )

        -- Discovering the boundering of the drawing;
        dMinY = mathTools.min( dMinY, minY )
        dMaxY = mathTools.max( dMaxY, maxY )
        dMinX = mathTools.min( dMinX, minX )
        dMaxX = mathTools.max( dMaxX, maxX )

        -- Finding the Rectangle that incapsulate
        local Q1 = Vector2D:new( minX, maxY )
        local Q2 = Vector2D:new( minX, minY )
        local Q3 = Vector2D:new( maxX, maxY )
        local Q4 = Vector2D:new( maxX, minY )

        -- Finding the equation of the line
        local m1 = (Q4.y - Q1.y) / (Q4.x - Q1.x)
        local m2 = (Q3.y - Q2.y) / (Q3.x - Q2.x)
        local b1 =  Q1.y - (m1 * Q1.x)
        local b2 =  Q2.y - (m2 * Q2.x)
        local x = (b2 - b1) / (m1 - m2)
        local y = m1 * x + b1

        local vertices = { A.x, A.y, C.x, C.y, D.x, D.y, B.x, B.y }
        local o = display.newPolygon( cur.x, cur.y, vertices )
        o.fill = pen.fill
        o.fill.rotation = rotation
        o.strokeWidth = 0
        o:setFillColor(
            lineColor[1],
            lineColor[2],
            lineColor[3],
            lineColor[4]
        )
        o.x = x
        o.y = y
        canvasGroup:insert( o )
    end

    function drawLines( linePoints )
        local numberOfVertices = #linePoints * 18

        --LineVertex *vertices = calloc(sizeof(LineVertex), numberOfVertices);

        local prevPoint = linePoints[1]
        local prevValue = prevPoint.width
        local curValue
        local index = 0
        for i = 2, #linePoints do
            local curPoint = linePoints[i]
            local curValue = curPoint.width
            -- equal points, skip them
            if Vector2D:equals( curPoint, prevPoint ) then
                return false
            end

            local dir = Vector2D:Sub( curPoint, prevPoint )
            local xDiff = prevPoint.x - curPoint.x
            local yDiff = prevPoint.y - curPoint.y
            local rotation =  math.atan2( yDiff, xDiff ) * (180 / math.pi)

            local perpendicular = Vector2D:Normalize( Vector2D:perpendicular( dir ) )
            local A = prevC
            local B = prevD
            if (A == nil and B == nil) then
                A = Vector2D:Add( prevPoint, Vector2D:Mult( perpendicular, prevValue / 2 ) )
                B = Vector2D:Sub( prevPoint, Vector2D:Mult( perpendicular, prevValue / 2 ) )
                ADD_CIRCLE( curPoint, rotation )
                ADD_CIRCLE( linePoints[#linePoints - 1], rotation )
            else
                ADD_CIRCLE( curPoint, rotation )
            end
            local C = Vector2D:Add( curPoint, Vector2D:Mult( perpendicular, curValue / 2 ) )
            local D = Vector2D:Sub( curPoint, Vector2D:Mult( perpendicular, curValue / 2 ) )
            -- continuing line

            prevD = D
            prevC = C

            if (finishingLine == true and (i == #linePoints)) then
                ADD_CIRCLE( linePoints[#linePoints - 1], rotation )
                ADD_CIRCLE( curPoint, rotation )

                finishingLine = false
            end

            prevPoint = curPoint
            prevValue = curValue

            --! Add overdraw
            local F = Vector2D:Add( A, Vector2D:Mult( perpendicular, pen.overdraw ) )
            local G = Vector2D:Add( C, Vector2D:Mult( perpendicular, pen.overdraw ) )
            local H = Vector2D:Sub( B, Vector2D:Mult( perpendicular, pen.overdraw ) )
            local I = Vector2D:Sub( D, Vector2D:Mult( perpendicular, pen.overdraw ) )
            --! end vertices of last line are the start of this one, also for the overdraw
            if (connectingLine == true or index > 6) then
                F = prevG
                H = prevI
            end

            prevG = G
            prevI = I
            ADD_RETANGLE( F, G, H, I, curPoint, 1, rotation )

            index = index + 1
        end

        if (index > 0) then
            connectingLine = true
        end
    end

    function calculateSmoothLinePoints()
        -- 1 We need at least 3 points to use quad curves.
        if (#points > 2) then
            local smoothedPoints = {}

            -- 2 Each time we need our current point and 2 previous ones.
            for i = 3, #points do
                local prev2 = points[i - 2]
                local prev1 = points[i - 1]
                local cur = points[i]

                -- 3 Calculate our middle points between touch points.
                local midPoint1 = Vector2D:Mult( Vector2D:Add( prev1, prev2 ), 0.5 )
                local midPoint2 = Vector2D:Mult( Vector2D:Add( cur, prev1 ), 0.5 )

                -- 4 Calculate number of segments, for each 2 pixels there will be one extra segment,
                -- minimum of 32 segments and maximum of 128. If 2 mid points would be 100 pixels apart
                -- we would have 50 segments, we need to make sure we have at least 32 segments or the bending will look aliased…
                local segmentDistance = 2;
                local distance = Vector2D:Dist( midPoint1, midPoint2 )
                local numberOfSegments = mathTools.min(
                    mathTools.max(
                        min,
                        mathTools.floor(distance / segmentDistance)
                    ),
                    max
                )

                -- 5 Calculate our interpolation t increase based on the number of segments.
                local t = 0
                local step = 1 / numberOfSegments
                for j = 1, numberOfSegments do
                    -- 6 Calculate our new points by using quad curve equation. Also use same interpolation for line width.
                    local newPoint = Vector2D:Add(
                        Vector2D:Add(
                            Vector2D:Mult( midPoint1, mathTools.pow(1 - t, 2) ),
                            Vector2D:Mult( prev1, 2 * (1 - t) * t )
                        ),
                        Vector2D:Mult( midPoint2, t * t )
                    )
                    newPoint.width = cur.width

                    table.insert( smoothedPoints, newPoint )
                    t = t + step
                end

                -- 7 Add final point connecting to our end point
                local finalPoint = {}
                finalPoint = midPoint2
                finalPoint.width = cur.width

                table.insert( smoothedPoints, finalPoint )
            end

            -- 8 Since we will be drawing right after this function, we don’t need old points except the last 2.
            -- That way each time user moves his finger we can draw next segment.
            local new_points = { points[#points - 1], points[#points] }
            points = new_points
            return smoothedPoints
        else
            return nil
        end
    end

    function draw()
        local smoothedPoints = calculateSmoothLinePoints()
        if (smoothedPoints) then
            drawLines( smoothedPoints )
        end
    end

    function extractSize( vec )
        local prevP = points[#points]
        if prevP then
            local d = mathTools.min(
                mathTools.max(
                    pen.minWidth,
                    Vector2D:Dist( vec, prevP )
                ),
                pen.maxWidth
            )
            return d
        else
            return pen.maxWidth
        end
    end

    function addPoint( vec, width )
        local point = vec
        point.width = width
        points[#points + 1] = point
        draw()
    end

    function startNewLineFrom( vec, width )
        connectingLine = false
        addPoint( vec, width )
    end

    function endLineAt( vec, width )
        finishingLine = true
        addPoint( vec, width )
    end

    function newLine( event )
        local point = Vector2D:new( event.x, event.y )
        local size = extractSize( point )

        if event.phase == "began" then
            -- Bouderies of the entire draw
            if dMinX == nil then dMinX = point.x end
            if dMaxX == nil then dMaxX = point.x end
            if dMinY == nil then dMinY = point.y end
            if dMaxY == nil then dMaxY = point.y end

            -- Bounderies of the last line
            if lMinX == nil then lMinX = point.x end
            if lMaxX == nil then lMaxX = point.x end
            if lMinY == nil then lMinY = point.y end
            if lMaxY == nil then lMaxY = point.y end

            prevC = nil
            prevD = nil
            points = {}
            velocities = {}

            startNewLineFrom( point, size )
            addPoint( point, size )
            addPoint( point, size )
        elseif event.phase == "moved" then
            -- skip points that are too close
            local eps = 1.5
            if #points > 0 then
                local length = Vector2D:Length( Vector2D:Sub( points[#points], point ) )
                if (length < eps) then
                    return false
                end
            end
            addPoint( point, size )
        elseif event.phase == "cancelled" or "ended" then
            endLineAt( point, size )
        end

        return true
    end


    -----------------------------------
    -- EVENT LISTENER TO DRAW LINES (required)
    -----------------------------------
    canvas:addEventListener( "touch", newLine )


    -----------------------------------
    -- Methods
    -----------------------------------
    canvasContainer.cleanDraw = function ()
        if canvasGroup then
            canvasGroup:removeSelf()
        end
        canvasGroup = nil
        canvasGroup = display.newGroup()
    end

    canvasContainer.changeColor = function ( colorArray )
        lineColor = colorArray
    end

    canvasContainer.changeWidth = function ( width )
        lineWidth = width
        pen.minWidth = lineWidth
        pen.maxWidth = lineWidth + 1
    end

    canvasContainer.saveAsImage = function ( imageName )
        createDrawBoundaries( dMaxX, dMinX, dMaxY, dMinY )
        display.save( canvasGroup, {
            filename = imageName,
            baseDir = system.DocumentsDirectory,
            isFullResolution = true,
        } )
    end

    canvasContainer.clean = function ()
        if canvasGroup then
            canvasGroup:removeSelf()
        end
        canvasGroup = nil

        if canvas then
            canvas:removeEventListener( "touch", newLine )
            canvas:removeSelf()
        end
        canvas = nil

        if canvasContainer then
            canvasContainer:removeSelf()
        end
        canvasContainer = nil

        lineColor = nil
        width = nil
        height = nil
        mathTools = nil
        points = nil
        velocities = nil
        connectingLine = nil
        finishingLine = nil
        prevValue = nil
        curValue = nil
        prevC = nil
        prevD = nil
        prevG = nil
        prevI = nil
        min = nil
        max = nil
        newLine = nil
        endLineAt = nil
        startNewLineFrom = nil
        addPoint = nil
        extractSize = nil
        draw = nil
        calculateSmoothLinePoints = nil
        drawLines = nil
        ADD_RETANGLE = nil
        ADD_CIRCLE = nil
    end

    return canvasContainer
end

return d;
