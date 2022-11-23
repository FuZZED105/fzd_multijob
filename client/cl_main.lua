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

RegisterNUICallback("getPlayerJobs", function(data, cb)
    QBCore.Functions.TriggerCallback('fzd_multijobs:server:GetPlayerJobs', function(jobs)
        local PlayerJobs = {}

        for name, job in pairs(jobs) do
            table.insert(PlayerJobs, {
                name = job.name,
                label = job.label,
                grade = job.grade,
                gradeLabel = job.gradeLabel,
                active = job.active
            })
        end

        cb(PlayerJobs)
    end)
end)

RegisterNUICallback("setActiveJob", function(data, cb)
    TriggerServerEvent('fzd_multijobs:server:setActiveJob', data.job)
    cb('ok')
end)