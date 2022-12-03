---------------- Create Application ------------------------------
local added, errorMessage = exports["lb-phone"]:AddCustomApp({
    identifier = "employment",
    name = "Employment",
    description = "Employment application",
    ui = GetCurrentResourceName() .. "/ui/index.html"
})

if not added then
    print("Could not add app:", errorMessage)
end

-------------------------------------------------------------------
local QBCore = exports['qb-core']:GetCoreObject()

local job = "unemployed"
local grade = 0

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if LocalPlayer.state['isLoggedIn'] then
		QBCore.Functions.GetPlayerData(function(PlayerData)
			job = PlayerData.job.name
            grade = PlayerData.job.grade.level
		end)
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    while QBCore.Functions.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    job = QBCore.Functions.GetPlayerData().job.name
    grade = QBCore.Functions.GetPlayerData().job.grade.level
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        job = PlayerData.job.name
        grade = PlayerData.job.grade.level
    end)

    if Config.AutoJobSavining then
        TriggerServerEvent("fzd_multijob:checkForJob")
    end
end)

RegisterNUICallback('getJobs', function(data, cb)
    if LocalPlayer.state['isLoggedIn'] then
    QBCore.Functions.TriggerCallback('fzd_multijob:getJobs', function(jobs)
        cb({
            job = { job = job, grade = grade },
            jobs = json.encode(jobs)
        })
        end)
    end
end)

RegisterNUICallback('removejob', function(data)
    TriggerServerEvent("fzd_multijob:removeJob", data.job, data.grade)
end)

RegisterNUICallback('changejob', function(data)
    TriggerServerEvent("fzd_multijob:changeJob", data.job, data.grade)
end)
