Config = {}

Config.MaxJobs = 3 -- Max amount of jobs a player can have. -1 for unlimited.
Config.AutoJobSavining = true -- If a job is set from another script, it will be saved to the database. If false on the command /addjob will give the the job.

Config.DefaultJobs = { -- Jobs that will be added in menu by default and wont be removable
    { job = 'casino', grade = 0 }
}
