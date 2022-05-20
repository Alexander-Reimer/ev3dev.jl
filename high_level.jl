function drive(motor::Motor, speed::Int; direct::Bool = true)
    drive(motor; direct = direct)
    change_speed(motor, speed)
end

function drive(robot::Robot, speed = nothing, turning_rate = nothing; direct = true)
    same = 0

    if speed === nothing
        speed = robot.current_speed
        same += 1
    else
        if speed == robot.speed
            same += 1
        else
            robot.speed = speed
        end
    end

    if turning_rate === nothing
        turning_rate = robot.turning_rate
        same += 1
    else
        if turning_rate == robot.turning_rate
            same += 1
        else
            robot.turning_rate = turning_rate
        end
    end

    if same != 2
        left_speed = speed
        right_speed = speed

        half_turn = round(Int, turning_rate / 2)

        left_speed += half_turn
        right_speed -= half_turn

        left_speed > 100 && (left_speed = 100)
        left_speed < -100 && (left_speed = -100)

        right_speed > 100 && (right_speed = 100)
        right_speed < -100 && (right_speed = -100)
        
        drive(robot.left, left_speed; direct = direct)
        drive(robot.right, right_speed; direct = direct)
    end
end

function stop(robot::Robot, stop_action::Symbol = :coast)
    stop(robot.left, stop_action)
    stop(robot.right, stop_action)
end

function mode(mode, sensors::LightSensor...)
    for sensor in sensors
        command(sensor, sensor.modes[mode])
    end
end