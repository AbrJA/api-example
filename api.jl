using Oxygen
using Dates
using JSON3

function writelog(level, msg)
    println("[ ", level, ": ", Dates.now(), " - ", msg, " ]")
end

global k_file = "./data/model.json"
global X = 0.0

@get "/api-test/check" function()
    return Dict("date" => Dates.now(), "value" => sum(X["x"]))
end

@cron "0 *" function()
    if isfile(k_file)
        global X = JSON3.read(k_file)
        rm(k_file)
        writelog("Info", "New model")
    end
end

# start the web server
@async Oxygen.serve()