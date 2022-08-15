--check the sky.lua file for everything else lol
--moved everything in there to reduce copied code and function calls




function onStepHit()
    --super saiyan thing
    if (curStep >= 4*16 and curStep <= 30*16) or (curStep >= 64*16 and curStep <= 80*16) or (curStep >= 114*16 and curStep <= 146*16) then 
        if curStep % 32 == 0 or curStep % 32 == 30 then 
            triggerEvent('Add Camera Zoom', 0.1, -0.06)
        end
    elseif (curStep >= 80*16 and curStep <= 96*16) or (curStep >= 146*16 and curStep <= 178*16) then 
        if curStep % 32 == 0 or curStep % 32 == 30 or curStep % 32 == 28 or curStep % 32 == 26 or curStep % 32 == 24 then 
            triggerEvent('Add Camera Zoom', 0.1, -0.06)
        end
    elseif curStep == 112*16 or curStep == (112*16)+4 or curStep == (113*16) or curStep == (113*16)+4 or curStep == (113*16)+8 or curStep == (113*16)+12 then 
        triggerEvent('Add Camera Zoom', 0.1, -0.06)
    end


    --beat shit
    if (curStep >= 12*16 and curStep <= 30*16) or (curStep >= 32*16 and curStep <= 96*16) or (curStep >= 112*16 and curStep <= 142*16) or (curStep >= 146*16 and curStep <= 178*16) then 
        if curStep % 4 == 0 then 
            triggerEvent('Add Camera Zoom', 0.02, -0.007)
        elseif curStep % 4 == 2 then 
            triggerEvent('Add Camera Zoom', 0.02, -0.007)
        end
    end

    if curStep == 178*16 then 
        triggerEvent('Add Camera Zoom', 0.1, 0.25)
    end
end

