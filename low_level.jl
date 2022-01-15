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

function map_motors(paths = ["tacho-motor/"])
    for path in paths
        N = 0
        println(ev3.mount_path * path * "motor" * string(N))
        while isdir(ev3.mount_path * path * "motor" * string(N))
            the_path = ev3.mount_path * path * "motor" * string(N) * "/"

            println(the_path)

            address_io = open(the_path * "address")
            contents = readline(address_io)
            close(address_io)

            name = split(contents, ":")[2] # "ev3-ports:outA" -> "outA"

            println(Symbol(name))

            make_port(Symbol(name), the_path)
            N += 1
        end
    end
end

function map_sensors(paths = ["lego-sensor/"])
    for path in paths
        for N = 1:100
            the_path = ev3.mount_path * path * "sensor" * string(N) * "/"
            if isdir(the_path)

                println(the_path)

                address_io = open(the_path * "address")
                contents = readline(address_io)
                close(address_io)

                name = split(contents, ":")
                name = map(p -> Symbol(p), name)

                if length(name) == 4
                    make_port(name[4], the_path)
                    println(name[4])
                elseif length(name) == 2
                    make_port(name[2], the_path)
                    println(name[2])
                end
            end
        end
    end
end

function map_ports()
    ports() # Create an empty Dictionary named "Ports"
    map_motors() # Add keys for the motors to Ports (keys named outA, outB, etc.)
    map_sensors() # Add keys for the sensors to Ports (keys named in1, in2, etc. for input ports, mux1, mux2, etc. for mux )
end

# IOs
function deactivate(motor::Motor)
    close(motor.command)
    close(motor.duty_cyle)
    close(motor.speed)
    close(motor.stop_action)
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

function stop(motor::Motor, stop_action::Symbol)
    # Stop actions:
    # :coast - Just stop spinning the motor and let it run out
    # :brake - Stop the motor actively
    # :hold - Stop the motors rotation and hold it still by applying force to counter any rotation

    write_flush(motor.stop_action, string(stop_action))
    command(motor, "stop")
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