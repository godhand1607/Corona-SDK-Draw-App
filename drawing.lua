---------------
-- Code By Paulo Peres Jr
-- For NuOffer Starting Date Jun 27 2014
---------------
-- Starting
-- local drawing = require("drawing"):new({
--		Color = {0.5,0.5,0.5,0.5}, -- Array of the colors you want
--		width = display.contentWidth, -- width of the drawing canvas
--		height = display.contentHeight, -- height of th drawing canvas
--	}); 
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


require "Vector2D"
local d = {}

function d:new(array)
	-- Parameters
	
	local lineColor = array.Color;
	local width = array.width or display.contentWidth;
	local height = array.height or display.contentHeight;
	-- Necessary Variables
	local group = display.newGroup();
	--group.anchorX = 0;
	--group.anchorY = 0;
	local canvas = display.newRect( 0, 0, width, height);

	local mMin = math.min;
	local mMax = math.max;
	local mFloor = math.floor;
	local mPow = math.pow;

	local points = {};
	local velocities = {};
	
	local connectingLine = false;
	local finishingLine = false;
	
	local prevValue = 0;
	local curValue = 0;
	local prevC;
	local prevD;
	local prevG;
	local prevI;
	-- INTERPOLATION OF THE SMOTH LINES
	local min = 5;
	local max = 15;
	-- Size of the overdraw to do anti-aliasing
	local overdraw  = 1.5;
	local triagleGroup = display.newGroup();
	group:insert(canvas);
	group:insert(triagleGroup);
	canvas.x = 0;
	canvas.y = 0;
	triagleGroup.x = -canvas.width*0.5;
	triagleGroup.y = -canvas.height*0.5
	--triagleGroup.x = 0;
	--triagleGroup.y = 0;
	local function ADD_CIRCLE(vec,rotation)
		
		local myCircle2 = display.newCircle( vec.x,vec.y, vec.width + overdraw*0.5 )
		
		
		myCircle2.fill = {
		    type = "image",
    		filename = "pen_pattern.png",
    		
		}
		myCircle2.fill.rotation = rotation;
		myCircle2.alpha = 0.8;
		myCircle2:setFillColor( lineColor[1],lineColor[2],lineColor[3],lineColor[4]);
		triagleGroup:insert(myCircle2);
	end
	
	local function ADD_RETANGLE(A, B, C,D,cur, val,rotation)
		
		--[[
		local star = display.newLine(  cur.x, cur.y, cur.x, cur.y )
		star:append(  A.x,A.y,C.x,C.y,D.x,D.y,B.x,B.y ,A.x,A.y )
		star:setStrokeColor( color[1],color[2],color[3] )
		star.strokeWidth = 1

		-- Eqation of the line
		-- y = m*x+b;
		local m1 = (D.y - A.y) / (D.x- A.x);
		local m2 = (C.y - B.y) / (C.x- B.x); 
		local b1 =  A.y - (m1 * A.x);
		local b2 =  B.y - (m2 * B.x);
		local x = (b2-b1)/(m1-m2);
		local y = m1*x+b1;

			--]]

		-- Finding the positions of the Rectangle
		local minY = mMin(A.y,mMin(B.y,mMin(C.y,D.y)));
		

		local maxY = mMax(A.y,mMax(B.y,mMax(C.y,D.y)));
		
		local minX = mMin(A.x,mMin(B.x,mMin(C.x,D.x)));
		local maxX = mMax(A.x,mMax(B.x,mMax(C.x,D.x)));
		-- Finding the Rectangle that incapsulate
		local Q1 = Vector2D:new(minX,maxY)
		local Q2 = Vector2D:new(minX,minY)
		local Q3 = Vector2D:new(maxX,maxY)
		local Q4 = Vector2D:new(maxX,minY);
		-- Finding the equation of the line
		local m1 = (Q4.y - Q1.y) / (Q4.x- Q1.x);
		local m2 = (Q3.y - Q2.y) / (Q3.x- Q2.x); 
		local b1 =  Q1.y - (m1 * Q1.x);
		local b2 =  Q2.y - (m2 * Q2.x);
		local x = (b2-b1)/(m1-m2);
		local y = m1*x+b1;

	--[[
		local star = display.newLine(  Q1.x, Q1.y, Q3.x, Q3.y )
		star:append(  Q4.x,Q4.y,Q2.x, Q2.y, Q1.x, Q1.y )
		star:setStrokeColor( 1, 1, 1, 0.8 )
		star.strokeWidth = 1
		]]--
		local vertices = { A.x,A.y,C.x,C.y,D.x,D.y,B.x,B.y }
		local o = display.newPolygon( cur.x,cur.y, vertices )
		--o.fill = { type="image", filename="pen_pattern.png" }

		o.fill = {
		    type = "image",
    		filename = "pen_pattern.png",
    		
		    

		}
		o.fill.rotation = rotation;
		--o.fill.effect = "composite.average"
		o.strokeWidth = 0;
		o:setStrokeColor( 1, 1, 1,0 )
		o:setFillColor( lineColor[1],lineColor[2],lineColor[3],lineColor[4]);

		triagleGroup:insert(o);
		--o.alpha = 0.9;
		o.anchorX = 0.5;
		o.anchorY = 0.5;
		o.x = x;
		o.y = y;
	--[[
		local newPoint = Vector2D:new( o.x, o.y)
		local myCircleC2 = display.newCircle( x, y, 2 )
		
		myCircleC2:setFillColor( color[1],color[2],color[3],0.5 )

		local myCircleC = display.newCircle( newPoint.x, newPoint.y, 2 )
		
		myCircleC:setFillColor( color[1],color[2],color[3] )
		
		local myCircle = display.newCircle( Q1.x, Q1.y, 2 )
		
		myCircle:setFillColor( color[1],color[2],color[3] )
		local myCircle2 = display.newCircle( Q2.x, Q2.y, 2 )
		
		myCircle2:setFillColor( color[1],color[2],color[3] )
		local myCircle3 = display.newCircle( Q3.x, Q3.y, 2 )
		
		myCircle3:setFillColor( color[1],color[2],color[3] )
		local myCircle4 = display.newCircle( Q4.x, Q4.y, 2 )
		
		myCircle4:setFillColor( color[1],color[2],color[3] )

		
		
		
		local myCircle = display.newCircle( cur.x, cur.y, 2 )
		myCircle:setFillColor( color[1],color[2],color[3] )
		local star = display.newLine(   o.x - o.width*0.5, o.y+o.height*0.5,  o.x - o.width*0.5, o.y+o.height*0.5 )
		
		star:setStrokeColor( color[1],color[2],color[3] )
		star.strokeWidth = 1
		star:append(   o.x - o.width*0.5, o.y+o.height*0.5)
		star:append( o.x + o.width*0.5, o.y+o.height*0.5)
		star:append(  o.x + o.width*0.5, o.y-o.height*0.5)
		star:append(  o.x - o.width*0.5, o.y-o.height*0.5 )
		]]--

		
		
		
	end

	local function drawLines(linePoints)
			local numberOfVertices = #linePoints * 18;

	 		--LineVertex *vertices = calloc(sizeof(LineVertex), numberOfVertices);

	  		local prevPoint = linePoints[1];
	  		local prevValue = prevPoint.width;
	  		local curValue;
	  		local index = 0;
	  		for i=2,#linePoints do
	  			local curPoint = linePoints[i]
	  			local curValue = curPoint.width;
	  			-- equal points, skip them
			    if (Vector2D:equals(curPoint, prevPoint) )then
			    	
			      	return false;
			    end
			   
			   
			    local dir = Vector2D:Sub(curPoint, prevPoint);
			    local xDiff = prevPoint.x - curPoint.x; 
			    local yDiff = prevPoint.y - curPoint.y; 
			    local rotation =  math.atan2(yDiff, xDiff) * (180 / math.pi); 

			    
			    local perpendicular = Vector2D:Normalize(Vector2D:perpendicular(dir));
			    local A = prevC;
			    local B = prevD;
			    if (A ==nil and B == nil) then
			    	A = Vector2D:Add(prevPoint, Vector2D:Mult(perpendicular, prevValue / 2));
			    	B = Vector2D:Sub(prevPoint, Vector2D:Mult(perpendicular, prevValue / 2));
			    	ADD_CIRCLE(curPoint,rotation);
			    	ADD_CIRCLE(linePoints[#linePoints -1],rotation);
			    	--print("Starting Line")
			    else
			    	ADD_CIRCLE(curPoint,rotation);
			    end
			    local C = Vector2D:Add(curPoint, Vector2D:Mult(perpendicular, curValue / 2));
			    local D = Vector2D:Sub(curPoint, Vector2D:Mult(perpendicular, curValue / 2));
			    -- continuing line
			    
			    prevD = D;
			    prevC = C;

			    if (finishingLine == true and (i == #linePoints)) then
			    	ADD_CIRCLE(linePoints[#linePoints -1],rotation);
			    	ADD_CIRCLE(curPoint,rotation);
			      --[circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
			      --[circlesPoints addObject:pointValue];
			      finishingLine = false;
			    end
			    prevPoint = curPoint;
			    prevValue = curValue;
			    --ADD_RETANGLE(A,B,C,D,curPoint,1,rotation);
			    --! Add overdraw
			    local F = Vector2D:Add(A, Vector2D:Mult(perpendicular, overdraw));
			    local G = Vector2D:Add(C, Vector2D:Mult(perpendicular, overdraw));
			    local H = Vector2D:Sub(B, Vector2D:Mult(perpendicular, overdraw));
			    local I = Vector2D:Sub(D, Vector2D:Mult(perpendicular, overdraw));
			    --! end vertices of last line are the start of this one, also for the overdraw
			    if (connectingLine== true or index > 6) then
			      F = prevG;
			      H = prevI;
			    end

			    prevG = G;
			    prevI = I;
			   	ADD_RETANGLE(F,G,H,I,curPoint,1,rotation);
			    --ADD_TRIANGLE(F, A, G, 2.0);
			    --ADD_TRIANGLE(A, G, C, 2.0);
			    --ADD_TRIANGLE(B, H, D, 2.0);
			    --ADD_TRIANGLE(H, D, I, 2.0);
			    index = index+1;
	  		end

		if (index > 0) then
			connectingLine = true;
		end

	end


	local function calculateSmoothLinePoints()

		-- 1 We need at least 3 points to use quad curves.
		
		if(#points > 2) then
			local smoothedPoints = {};
			-- 2 Each time we need our current point and 2 previous ones.
			for i=3,#points do
				--print(i);
				local prev2 = points[i - 2];
			    local prev1 = points[i - 1];
			    local cur = points[i];
			   
			   -- print(prev2,prev1,cur,#points)
			    -- 3 Calculate our middle points between touch points.
				local midPoint1 = Vector2D:Mult(Vector2D:Add(prev1, prev2), 0.5);
			    local midPoint2 = Vector2D:Mult(Vector2D:Add(cur, prev1), 0.5);
			    -- 4 Calculate number of segments, for each 2 pixels there will be one extra segment, 
				-- minimum of 32 segments and maximum of 128. If 2 mid points would be 100 pixels apart 
				-- we would have 50 segments, we need to make sure we have at least 32 segments or the bending will look aliased…
				local segmentDistance = 2;
		      	local distance = Vector2D:Dist(midPoint1, midPoint2);
		      	local numberOfSegments = mMin(mMax(min, mFloor(distance/segmentDistance)), max);
		      	--print(distance,numberOfSegments)
		      	-- 5 Calculate our interpolation t increase based on the number of segments.
		      	local t = 0;
			    local step = 1 / numberOfSegments;
			    for j=1,numberOfSegments do
			    	-- 6 Calculate our new points by using quad curve equation. Also use same interpolation for line width.
			    	local newPoint = Vector2D:Add(Vector2D:Add(Vector2D:Mult(midPoint1, mPow(1 - t, 2)), Vector2D:Mult(prev1, 2 * (1 - t) * t)), Vector2D:Mult(midPoint2, t * t));
			       	newPoint.width = math.pow(1 - t, 2) * ((prev1.width + prev2.width) * 0.5) + 2.0 * (1 - t) * t * prev1.width * t * t * ((cur.width + prev1.width) * 0.5);
			     	--print(newPoint.width)
			     	--newPoint.width = 2;
			        table.insert(smoothedPoints, newPoint);
			        t = t + step;
			    end
			    -- 7 Add final point connecting to our end point
			    local finalPoint = {};
			    finalPoint = midPoint2;
			    
			    finalPoint.width = (cur.width ) * 0.5;
			    
			    --finalPoint.width = 2;
			    table.insert(smoothedPoints, finalPoint);
			   
				
			end
			
			-- 8 Since we will be drawing right after this function, we don’t need old points except the last 2. That way each time user moves his finger we can draw next segment.
			local new_points = {points[#points-1],points[#points]} 
			points= nil;
			points ={};
			points = new_points;
			return smoothedPoints;
		else
			return nil;
		end
	end
	local function draw()
		local smoothedPoints = calculateSmoothLinePoints();
		if (smoothedPoints) then
			drawLines(smoothedPoints)
		end

	end

	local function extractSize(vec)

	  --! result of trial & error
	  local vel = Vector2D:Length(vec);

	  local size = vel / 160.0;
		
	  size = mMin(mMax(1, size), 4);

	  if #velocities > 1 then
	    	--size = size * 0.2 / velocities[#velocities-1] *0.5;
	  end
	  
	  --size =2;
	  table.insert(velocities,size);
	  
	  return size;
	end

	local function addPoint(vec,width)
		local point = vec;
		point.width = width;
		points[#points+1] = point;
		draw();
		--calculateSmoothLinePoints();
	end
	local function startNewLineFrom(vec,width)
		connectingLine = false;
		addPoint(vec,width);
	end
	local function endLineAt(vec,width)
		addPoint(vec,width);
		finishingLine = true;
	end

	local newLine = function(event)
	 	local point = Vector2D:new(event.x,event.y);
	    
		if event.phase=="began" then
			prevC = nil;
			prevD = nil;
			points = {};
			velocities = {};

			local size = extractSize(point);

			startNewLineFrom(point,size);
			addPoint(point,size);
			addPoint(point,size);
		elseif event.phase=="moved" then
			-- skip points that are too close
			local eps = 1.5;
			if #points > 0 then
			  local length = Vector2D:Length(Vector2D:Sub(points[#points], point));

			  if (length < eps) then
			    return false;
			  end
			end
			local size = extractSize(point);
			addPoint(point,size);

		elseif event.phase=="cancelled" or "ended" then
			local size = extractSize(point);
			endLineAt(point,size);
		end
		return true
	end     
	 
	 
	-----------------------------------
	-- EVENT LISTENER TO DRAW LINES (required)
	-----------------------------------
	canvas:addEventListener("touch",newLine)
	-----------------------------------
	-- Methods
	-----------------------------------

	group.cleanDraw = function()
		if triagleGroup then 
			triagleGroup:removeSelf();
			triagleGroup = nil;
		end
		triagleGroup = display.newGroup();
	end
	group.changeColor = function(colorArray)
		lineColor = colorArray
	end
	group.saveAsImage = function(imageName)
	end
	group.clean = function()

		if triagleGroup then
			triagleGroup:removeSelf();
		end
		triagleGroup =nil;
		if canvas then
			canvas:removeEventListener("touch",newLine);
			canvas:removeSelf();
		end
		if group then 
			group:removeSelf();
		end
		group = nil;
		canvas = nil
		lineColor =nil;
		width = nil;
		height = nil
		mMin = nil;
		mMax = nil;
		mFloor = nil;
		mPow = nil;
		points = nil;
		velocities = nil;
		connectingLine = nil;
		finishingLine = nil;
		prevValue = nil;
		curValue = nil;
		prevC = nil;
		prevD = nil;
		prevG = nil;
		prevI = nil;
		min = nil;
		max = nil;
		overdraw = nil;
		newLine = nil;
		endLineAt = nil;
		startNewLineFrom = nil; 
		addPoint = nil;
		extractSize = nil;
		draw = nil;
		calculateSmoothLinePoints = nil;
		drawLines = nil;
		ADD_RETANGLE = nil;
		ADD_CIRCLE = nil;

	end
	return group;
end
return d;