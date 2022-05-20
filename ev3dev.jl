include("devices.jl")
include("low_level.jl")
include("high_level.jl")

function setup(path::String; device = :EV3Brick)
    if path[end] != '/'
        path = path * "/"
    end
    global brick = Brick(path, device)
    map_ports()
end

function setup()
    path = "R:"
    setup(path, device = :BrickPi)
end

setup()