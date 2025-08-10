fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'AbstractCoding'
description 'Simple street dice game for QBCore'
version '1.3.0'

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
    'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/assets/*.js',
	'html/assets/*.css',
	'html/**/*'
}
