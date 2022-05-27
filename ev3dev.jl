include("devices.jl")
include("low_level.jl")
include("high_level.jl")

function setup(path::String; device = :EV3Brick)
    if path[end] != '/'
        path = path * "/"
    end
    global brick = make_brick(path, device)
    map_ports()
end

function setup()
    path = "R:/sys/class"
    setup(path, device = :BrickPi)
end

setup()