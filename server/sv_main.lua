local QBCore = exports['qb-core']:GetCoreObject()

local Jobs = {}

local function GetPlayerJobs(citizenid)
    local jobs = {}

    for name, job in pairs(Jobs) do
        if job and job.employees and job.employees[citizenid] then
            jobs[name] = job.employees[citizenid]
        end
    end

    return jobs
end exports('GetPlayerJobs', GetPlayerJobs)

local function AddPlayerToJob(citizenid, job, grade)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    local Job = QBCore.Shared.Jobs[job]

    if not citizenid or not job or not Jobs[job] or job == "unemployed" then
        return false
    end

    if Jobs[job].employees[citizenid] then
        return false
    end

    Jobs[job].employees[citizenid] = {
        name = job,
        label = Job.label,
        grade = grade,
        gradeLabel = Job.grades[tostring(grade)].name,
        active = false
    }

    MySQL.update('UPDATE phone_jobs SET employees = ? WHERE name = ?',{json.encode(Jobs[job].employees), job})
end exports('AddPlayerToJob', AddPlayerToJob)

local function RemovePlayerFromJob(citizenid, job)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

    if not citizenid or not job or not Jobs[job] or job == "unemployed" then
        return false
    end

    if not Jobs[job].employees[citizenid] then
        return false
    end

    Jobs[job].employees[citizenid] = nil

    MySQL.update('UPDATE phone_jobs SET employees = ? WHERE name = ?',{json.encode(Jobs[job].employees), job})
end exports('RemovePlayerFromJob', RemovePlayerFromJob)

local function SetActiveJob(citizenid, job, active)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

    if not citizenid or not job or not Jobs[job] or job == "unemployed" then
        return false
    end

    if not Jobs[job].employees[citizenid] then
        return false
    end

    for name, job in pairs(Jobs) do
        if job.employees[citizenid] then
            job.employees[citizenid].active = false
        end
    end

    Jobs[job].employees[citizenid].active = active

    if Player.PlayerData.job.name == job then
        Player.Functions.SetJobDuty(Jobs[job].employees[citizenid].active)
        TriggerClientEvent('QBCore:Client:SetDuty', Player.PlayerData.source, Player.PlayerData.job.onduty)
    else
        Player.Functions.SetJob(job, Jobs[job].employees[citizenid].grade)

        Citizen.Wait(100)

        if Player.PlayerData.job.onduty and not Jobs[job].employees[citizenid].active then
            Player.Functions.SetJobDuty(false)
            TriggerClientEvent('QBCore:Client:SetDuty', Player.PlayerData.source, Player.PlayerData.job.onduty)
        else
            Player.Functions.SetJobDuty(true)
            TriggerClientEvent('QBCore:Client:SetDuty', Player.PlayerData.source, Player.PlayerData.job.onduty)
        end
    end

    MySQL.update('UPDATE phone_jobs SET employees = ? WHERE name = ?',{json.encode(Jobs[job].employees), job})
end exports('SetActiveJob', SetActiveJob)

Citizen.CreateThread(function()
    while not QBCore do Citizen.Wait(100) end

    for name, job in pairs(QBCore.Shared.Jobs) do
        if name ~= "unemployed" then
            local result = MySQL.query.await('SELECT * FROM phone_jobs WHERE name = ?', {name})

            if result[1] then
                for _, job in pairs(result) do
                    if not Jobs[job.name] then
                        Jobs[job.name] = {
                            employees = json.decode(job.employees)
                        }
                    end
                end
            else
                if not Jobs[name] then
                    Jobs[name] = {
                        employees = {}
                    }
                end

                local players = MySQL.query.await("SELECT * FROM players WHERE job LIKE ?", {('%%%s%%'):format(name)})

                for id, player in pairs(players) do
                    if player.job then
                        local grade = json.decode(player.job).grade.level or false

                        if grade and QBCore.Shared.Jobs[name].grades[tostring(grade)] then
                            if not Jobs[name].employees[player.citizenid] then
                                Jobs[name].employees[player.citizenid] = {
                                    name = name,
                                    label = QBCore.Shared.Jobs[name].label,
                                    grade = grade,
                                    gradeLabel = QBCore.Shared.Jobs[name].grades[tostring(grade)].name,
                                    active = true
                                }
                            end
                        end
                    end
                end

                MySQL.execute.await('INSERT INTO phone_jobs (name, employees) VALUES (?, ?)', {name, json.encode(Jobs[name].employees)})
            end
        end
    end
end)

QBCore.Functions.CreateCallback('fzd_multijobs:server:GetPlayerJobs', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local jobs = GetPlayerJobs(Player.PlayerData.citizenid)
        cb(jobs)
    else
        cb(false)
    end
end)

RegisterNetEvent('fzd_multijobs:server:setActiveJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        SetActiveJob(Player.PlayerData.citizenid, job.name, not job.active)
    end
end)