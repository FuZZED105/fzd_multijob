fx_version "cerulean"
game "gta5"

lua54 "yes"

title "LB Phone - App Template"
description "A template for creating apps for the LB Phone."
author "Breze"

shared_scripts {
    'config.lua'
}

client_scripts {
    "client/cl_main.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/sv_main.lua",
}

files {
    "ui/*"
}

ui_page 'ui/index.html'
