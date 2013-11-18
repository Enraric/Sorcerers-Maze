%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


View.Set ("graphics:800;600,offscreenonly,nobuttonbar")


var * keys : array char of boolean
const * UP := chr (119)
const * DOWN := chr (115)
const * LEFT := chr (97)
const * RIGHT := chr (100)
const * SPACE := chr (32)
var text := Font.New ("Serif:14")




class wizard
    export update, draw
    
    
    var x, y : int := 100
    var health, mana : real := 50.0
    var hasKey : boolean
    var speed : int := 3
    
    
    proc heal
        if mana > 0 then
            mana -= 1
            health += 1
        end if
        if health > 100 then
            health := 100
        end if
    end heal
    
    
    proc update
        if mana <= 100 then
            mana += 0.05
        end if
        if keys (UP) then
            y += speed
        elsif keys (DOWN) then
            y -= speed
        elsif keys (LEFT) then
            x -= speed
        elsif keys (RIGHT) then
            x += speed
        end if
        if keys (SPACE) then
            heal
        end if
    end update
    
    
    proc draw
        Draw.FillOval (x, y, 20, 20, red)
        
        for i : 0 .. 3
            Draw.FillBox (0, maxy-40, round (health * 2), maxy - i * 10, 47 + i)
        end for
            
        for i : 0 .. 3
            Draw.FillBox (0, maxy-60, round (mana * 2), maxy - 41 - i * 5, 32 + i)
        end for
    end draw
    
    
end wizard



var w : ^wizard
new w
loop
    Draw.FillBox (0, maxy-60, maxx, maxy, black)
    Font.Draw ("Health", 210, maxy-25, text, white)
    Font.Draw ("Mana", 210, maxy-50, text, white)
    Input.KeyDown (keys)
    w -> update
    w -> draw
    View.Update
    cls
    Time.DelaySinceLast (16)
end loop
