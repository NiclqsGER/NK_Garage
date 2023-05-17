fx_version 'cerulean'
games { 'gta5' }

author 'NiclqsGER'
description 'Github.com/NiclqsGER'
version '1.0.0'

client_scripts {
	'config/locales/list.lua',
	'config/conf.lua',
	'config/garage.lua',
    'client/client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}

ui_page "client/html/index.html"

files {
    "client/html/**/*.*",
}