function unknown_device()
    @error "$(brick.device) is unsupported! Only :EV3Brick and :BrickPi are!"
end
# Ports
function ports()
    global Ports = Dict{Symbol,String}()
end

function make_port(name, value)
    Ports[name] = value
    #=
    exp = Meta.parse("$name = \"$value\"")
    eval(exp)
    =#
end

function map_motors(path = "tacho-motor/")
    N = 0
    println(brick.mount_path * path * "motor" * string(N))
    while isdir(brick.mount_path * path * "motor" * string(N))
        the_path = brick.mount_path * path * "motor" * string(N) * "/"

        #println(the_path)

        address_io = open(the_path * "address")
        contents = readline(address_io)
        close(address_io)

        name = split(contents, ":")[2] # "brick-ports:outA" -> "outA", "spi0.1:MA" -> "MA"
        println(name)
        make_port(Symbol(name), the_path)
        N += 1
    end
end

function map_sensors(path)
    if brick.device == :EV3Brick
        path_type = "sensor"
    elseif brick.device == :BrickPi
        path_type = "port"
    else
        unknown_device()
    end
    for N = 0:20
        the_path = brick.mount_path * path * path_type * string(N) * "/"
        println(the_path)
        if isdir(the_path)
    
    
            address_io = open(the_path * "address")
            contents = readline(address_io)
            close(address_io)
    
            name = split(contents, ":")[end]
    
            if brick.device == :BrickPi
                if name[1] == 'S'
                    make_port(Symbol(name), the_path)
                end
            else
                make_port(Symbol(name), the_path)
            end
        end
    end
end

function map_ports()
    ports() # Create an empty Dictionary named "Ports"
    map_motors() # Add keys for the motors to Ports (keys named outA, outB, etc.)
    if brick.device == :EV3Brick
        map_sensors("lego-sensor/") # Add keys for the sensors to Ports (keys named in1, in2, etc. for input ports, mux1, mux2, etc. for mux )
    elseif brick.device == :BrickPi
        map_sensors("lego-port/")
    end
end

# IOs
function deactivate(motor::Motor)
    close(motor.command)
    close(motor.duty_cyle)
    close(motor.speed)
    close(motor.stop_action)
end

function deactivate(robot::Robot)
    deactivate(robot.left)
    deactivate(robot.right)
end

function deactivate(light_sensor::LightSensor)
    close(light_sensor.mode)
    close(light_sensor.value0)
    close(light_sensor.value1)
    close(light_sensor.value2)
end

function setdown(devices...)
    for device in devices
        deactivate(device)
    end
end

# Device control

function write_flush(io::IOStream, x)
    write(io, x)
    flush(io)
end

function command(motor::Motor, command::String)
    write_flush(motor.command, command)
end

function drive(motor::Motor; direct::Bool=true)
    if direct
        mode = (:direct, "run-direct")
    else
        mode = (:speed, "run-forever")
    end
    if motor.drive_mode != mode[1]
        command(motor, mode[2])
        motor.drive_mode = mode[1]
    end
end

function change_speed(motor::Motor, speed)
    if speed != motor.current_speed
        if motor.drive_mode == :direct
            write_flush(motor.duty_cyle, string(speed)) # Check later
        elseif motor.drive_mode == :speed
            write_flush(motor.speed, string(speed)) # Check later
            command(motor, "run-forever")
        end
        motor.current_speed = speed
    end
end

function stop(motor::Motor, stop_action::Symbol=:coast)
    # Stop actions:
    # :coast - Just stop spinning the motor and let it run out
    # :brake - Stop the motor actively
    # :hold - Stop the motors rotation and hold it still by applying force to counter any rotation

    if motor.current_stop_action != stop_action
        motor.current_stop_action = stop_action
        write_flush(motor.stop_action, string(stop_action))
    end
    if motor.drive_mode != :stop
        motor.drive_mode = :stop
        command(motor, "stop")
    end
end

function command(light_sensor::LightSensor, command::String)
    write_flush(light_sensor.mode, command)
end

function value(light_sensor::LightSensor)
    if light_sensor.current_mode == :RGB
        seekstart(light_sensor.value0)
        seekstart(light_sensor.value1)
        seekstart(light_sensor.value2)
        return (
            parse(Int, readline(light_sensor.value0)),
            parse(Int, readline(light_sensor.value1)),
            parse(Int, readline(light_sensor.value2)))
    else
        seekstart(light_sensor.value0)
        return parse(Int, readline(light_sensor.value0))
    end
end