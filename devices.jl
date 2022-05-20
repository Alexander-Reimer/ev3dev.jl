# Devices
mutable struct Motor
    port::String
    command::IOStream # IOStream controlling the command
    drive_mode::Symbol
    duty_cyle::IOStream
    speed::IOStream
    stop_action::IOStream
    current_speed::Int # For speed_sp AND duty_cycle_sp
    current_stop_action::Symbol
end

function Motor(port::String)
    command = open(port * "command", write = true, read = false)
    duty_cyle = open(port * "duty_cycle_sp", write = true, read = false)
    speed = open(port * "speed_sp", write = true, read = false)
    stop_action = open(port * "stop_action", write = true, read = false)

    write_flush(command, "reset")

    return Motor(port, command, :none, duty_cyle, speed, stop_action, 0, :none)
end

function Motor(port::Symbol)
    return Motor(Ports[port])
end


mutable struct LightSensor
    port::String
    mode::IOStream
    modes::Dict{Symbol,String}
    value0::IOStream
    value1::IOStream
    value2::IOStream
    current_mode::Symbol
end

function LightSensor(port::String)
    mode = open(port * "mode", write = true, read = false)
    value0 = open(port * "value0", read = true)
    value1 = open(port * "value1", read = true)
    value2 = open(port * "value2", read = true)
    modes = Dict(
        :reflection => "COL-REFLECT",
        :color => "COL-COLOR",
        :ambient => "COL-AMBIENT",
        :rgb => "RGB-RAW"
    )

    write(mode, modes[:reflection])
    return LightSensor(port, mode, modes, value0, value1, value2, :reflection)
end

function LightSensor(port::Symbol)
    return LightSensor(Ports[port])
end

function unknown_controller(device)
    msg = "$device is unsupported! Only the following \"controllers\" are supported: \n $supported_controllers"
    throw(AssertionError(msg))
end
mutable struct Brick
    mount_path::String
    device::Symbol
end

const supported_controllers = [:EV3Brick, :BrickPi]

function make_brick(mount_path, device)
    if device in supported_controllers
        return Brick(mount_path, device)
    else
        unknown_controller(device)
    end
end
mutable struct Robot
    left::Motor
    right::Motor
    speed::Int
    turning_rate::Float64
end

function Robot(left::Motor, right::Motor)
    return Robot(left, right, 0, 0)
end