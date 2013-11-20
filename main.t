%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Variable Declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const * UP := chr (119)
const * DOWN := chr (115)
const * LEFT := chr (97)
const * RIGHT := chr (100)
const * SPACE := chr (32)
var * keys : array char of boolean
var * text := Font.New ("Serif:14")
type * wizard : forward
type * goblin : forward

%Item Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * item
    export initialize, use, draw
    
    var pic : int
    
    proc initialize(p : int)
        
    end initialize
    
    deferred proc use
    
    proc draw(i : int)
        %Pic.Draw(48 * i + 50)
    end draw
end item

class _moveable
    export draw, setXY, x, y
    var x, y : int
    var health : real
    var speed : int
    
    deferred proc draw
    
    proc setXY(nx, ny : int)
        x := nx
        y := ny
    end setXY
end _moveable

%Wizard Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class _wizard
    inherit _moveable
    export update
    
    %setXY(100, 100)
    x := 100
    y := 100
    speed := 3
    health := 50.0
    var mana := 50.0
    
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
        if mana < 100 then
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
    
    
    body proc draw
        Draw.FillOval (x, y, 20, 20, red)
        
        for i : 0 .. 3
            Draw.FillBox (0, maxy-40, round (health * 2), maxy - i * 10, 47 + i)
        end for
            
        for i : 0 .. 3
            Draw.FillBox (0, maxy-60, round (mana * 2), maxy - 41 - i * 5, 32 + i)
        end for
    end draw
    
end _wizard
type wizard : ^_wizard

% Goblin Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class _goblin
    inherit _moveable
    export update
    
    %setXY(300, 300)
    x := 300
    y := 300
    health := 1.0
    speed := 2
    var randmove := Rand.Int (0, 4)
    var step := 0
    
    proc update(p : wizard)
        /*
        step += 1
        if step = 50 then
        randmove := Rand.Int(1,4)
        step := 0
        end if
        if randmove = (1) then
        y += speed
    elsif randmove = (2) then
        y -= speed
    elsif randmove = (3) then
        x -= speed
    elsif randmove = (4) then
        x += speed
        end if*/
        if x > ^p.x+5 then
            x -= speed
        elsif x < ^p.x-5 then 
            x += speed
        else
            if y > ^p.y+5 then
                y -= speed
            elsif y < ^p.y-5 then
                y += speed
            end if
        end if
    end update
    
    
    body proc draw
        Draw.FillOval (x, y, 20, 20, purple)
    end draw
    
end _goblin
type goblin : ^_goblin

%Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set ("graphics:800;600,offscreenonly,nobuttonbar")
var g : goblin
new g
var w : wizard
new w
loop
    Draw.FillBox (0, maxy-60, maxx, maxy, black)
    Font.Draw ("Health", 210, maxy-25, text, white)
    Font.Draw ("Mana", 210, maxy-50, text, white)
    Input.KeyDown (keys)
    w -> update
    w -> draw
    g -> update(w)
    g -> draw
    View.Update
    cls
    Time.DelaySinceLast (16)
end loop
