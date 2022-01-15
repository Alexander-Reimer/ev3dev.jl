include("devices.jl")
include("low_level.jl")
include("high_level.jl")

function setup(path)
    global ev3 = EV3(path)
    map_ports()
end

function setup()
    path = "mount/sys/class"
    setup(path)
end

setup()