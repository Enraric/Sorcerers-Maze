setscreen("graphics:450;100000000")
Font.StartName
var i := 1
loop
    var a := Font.GetName
    exit when a = ""
    if a(1) ~= "@" then
    Font.Draw(a, 0, maxy-(16*i), Font.New(a+":10"), black)
    i += 1
    end if
end loop
