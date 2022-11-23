local QBCore = exports['qb-core']:GetCoreObject()

local Jobs = {}

Citizen.CreateThread(function()
    while QBCore == nil do Wait(100) end

    for name, job in pairs(QBCore.Shared.Jobs) do
        Jobs[name] = {}
        Jobs[name].label = job.label
        Jobs[name].grades = {}

        for grade, gradeData in pairs(job.grades) do
            Jobs[name].grades[tonumber(grade)] = gradeData
        end
    end
end)

function AddJob(citizenid, job, grade, rem)
    MySQL.insert('INSERT INTO phone_jobs (citizenid, job, grade, removeable) VALUES (?, ?, ?, ?)', {citizenid, job, grade, rem})
end

function RemoveJob(citizenid, job, grade)
    MySQL.query('DELETE FROM phone_jobs WHERE citizenid = ? AND job = ? AND grade = ?', { citizenid, job, grade })

    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player ~= nil then
        if tostring(Player.PlayerData.job.name) == tostring(job) and tonumber(Player.PlayerData.job.grade.level) == tonumber(grade) then
            Player.Functions.SetJob('unemployed', 0)
        end
    end
end

QBCore.Commands.Add('addjob', 'Give a player access to a job', {
    { name = 'id', help = 'Player ID' },
    { name = 'job', help = 'Job Name' },
    { name = 'grade', help = 'Job Grade' }
}, true, function(source, args)
    if source ~= 0 then
        local Player = QBCore.Functions.GetPlayer(tonumber(source))

        if args[1] ~= nil then
            local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))

            if Target then
                if args[2] and args[3] ~= nil then
                    AddJob(Target.PlayerData.citizenid, args[2], args[3], true)
                else
                    TriggerClientEvent('QBCore:Notify', source, 'Wrong Usage', 'error')
                end
            else
                Player.Functions.Notify('Player is not online', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Wrong Usage', 'error')
        end
    end
end, 'admin')

QBCore.Commands.Add('removejob', 'Remove a players access to a job', {
    { name = 'id', help = 'Player ID' },
    { name = 'job', help = 'Job Name' },
    { name = 'grade', help = 'Job Grade' }
}, true, function(source, args)
    if source ~= 0 then
        local Player = QBCore.Functions.GetPlayer(tonumber(source))

        if args[1] ~= nil then
            local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))

            if Target then
                if args[2] and args[3] ~= nil then
                    RemoveJob(Target.PlayerData.citizenid, args[2], args[3], true)
                else
                    TriggerClientEvent('QBCore:Notify', source, 'Wrong Usage', 'error')
                end
            else
                Player.Functions.Notify('Player is not online', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Wrong Usage', 'error')
        end
    end
end, 'admin')

QBCore.Functions.CreateCallback('fzd_multijob:getJobs', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.query('SELECT * FROM phone_jobs WHERE citizenid = ?', {Player.PlayerData.citizenid}, function(jobs)
        local PlayerJobs = {}
        local online = {}

        local Players = QBCore.Functions.GetPlayers()

        for i = 1, #Players, 1 do
            local Target = QBCore.Functions.GetPlayer(tonumber(Players[i]))
            local TargetJob = Target.PlayerData.job

            if online[TargetJob.name] ~= nil then
                online[TargetJob.name] = online[TargetJob.name] + 1
            else
                online[TargetJob.name] = 1
            end
        end

        for _, v in pairs(jobs) do
            local on = online[v.job]

            if on == nil then
                on = 0
            end

            table.insert(PlayerJobs, {
                name = v.job,
                label = Jobs[v.job].label,
                grade = v.grade,
                gradeLabel = Jobs[v.job].grades[v.grade].name,
                salary = Jobs[v.job].grades[v.grade].payment,
                online = on,
                removeable = v.removeable
            })
        end

        for _, v in pairs(Config.DefaultJobs) do
            local on = online[v.job]

            if on == nil then
                on = 0
            end

            table.insert(PlayerJobs, {
                name = v.job,
                label = Jobs[v.job].label,
                grade = v.grade,
                gradeLabel = Jobs[v.job].grades[v.grade].name,
                salary = Jobs[v.job].grades[v.grade].payment,
                online = on,
                removeable = false
            })
        end

        cb(PlayerJobs)
    end)
end)

RegisterNetEvent('fzd_multijob:changeJob', function(job, grade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.SetJob(job, grade)
end)

RegisterNetEvent('fzd_multijob:checkForJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.query('SELECT * FROM phone_jobs WHERE citizenid = ?', {Player.PlayerData.citizenid}, function(jobs)
        local add = true
        local amount = 0

        local job = Player.PlayerData.job

        for _, v in pairs(jobs) do
            if job.name == v.job then
                add = false
            end
            amount = amount + 1
        end

        for _, v in pairs(Config.DefaultJobs) do
            if job.name == v.job then
                add = false
            end
            amount = amount + 1
        end

        if add and amount < Config.MaxJobs or Config.MaxJobs == -1 then
            if job.name == 'unemployed' then return end
            AddJob(Player.PlayerData.citizenid, job.name, job.grade, true)
        end
    end)
end)

RegisterNetEvent('fzd_multijob:removeJob', function(job, grade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    RemoveJob(Player.PlayerData.citizenid, job, grade)
end)