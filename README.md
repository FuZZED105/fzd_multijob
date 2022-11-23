# fzd_multijob - App for LB-Phone

This is an app I create for LB-Phone, in this read me you will be told how to install the for your phone.

First you will need to execute the SQL files, so we have a place you store the jobs and the players with the job.

Then you will need to make some edits to your command file in your core. Head over to qb-core/server/commands.lua and look for the /setjob command, once you have found the command, add this export under QBCore.Functions.SetJob

`exports.fzd_multijob:AddPlayerToJob(Player.PlayerData.citizenid, tostring(args[2]), tonumber(args[3]))`

So it should look like this

```
QBCore.Commands.Add('setjob', Lang:t("command.setjob.help"), { { name = Lang:t("command.setjob.params.id.name"), help = Lang:t("command.setjob.params.id.help") }, { name = Lang:t("command.setjob.params.job.name"), help = Lang:t("command.setjob.params.job.help") }, { name = Lang:t("command.setjob.params.grade.name"), help = Lang:t("command.setjob.params.grade.help") } }, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
        exports.fzd_multijob:AddPlayerToJob(Player.PlayerData.citizenid, tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')
```

Now we need to create a remove job under the setjob command like so

```
QBCore.Commands.Add('removejob', 'Removes A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' } }, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        if Player.PlayerData.job.name == tostring(args[2]) then
            Player.Functions.SetJob("unemployed", 0)
        end
        exports.fzd_multijob:RemovePlayerFromJob(Player.PlayerData.citizenid, tostring(args[2]))
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')
```

Now drag fzd_multijob into your resources and make sure it is started, launch your server and do `/setjob [id] [job name] [grade]` open your phone download the app in the app store and you should see your job, you can add as many jobs as you want to yourself.
