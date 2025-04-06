name '00_garage by sum00er'
author 'sum00er'
version '1.0.0'
fx_version 'cerulean'
game 'gta5'
ui_page 'dist/web/index.html'
lua54 'yes'

files {
	'dist/web/index.html',
	'dist/web/assets/index.js',
	'dist/web/assets/index.css',
	'locales/*.json',
	'locales/en.json',
}

dependencies {
	'/server:7290',
	'/onesync',
	'ox_lib'
}

shared_scripts {'@es_extended/imports.lua', '@ox_lib/init.lua', 'config.lua'}

client_scripts {
	'client/framework.lua',
	'client/main.lua',
	'client/function.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

escrow_ignore {
	'config.lua',
	'client/framework.lua',
	'client/main.lua',
	'server/framework.lua',
	'server/main.lua',
}
