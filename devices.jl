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

    write_flush(command, "stop")
    write_flush(speed, "0")
    write_flush(duty_cyle, "0")

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


mutable struct EV3
    mount_path::String
end

function EV3()
    return EV3("mount/sys/class/")
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