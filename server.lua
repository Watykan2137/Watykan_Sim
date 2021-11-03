ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('watykan_sim:useSIM')
AddEventHandler('watykan_sim:useSIM', function(itemLabel)
    local phoneNumber = string.sub(itemLabel, 14)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier AND `number` = @sim', {
        ['@identifier'] = xPlayer.identifier,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            print('jd')
            if sim[1].used == '0' then
                MySQL.Async.execute(
                    'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 0 WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 1 WHERE number = @phone_number',
                    {
                        ['@phone_number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Aktywowano karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerEvent('gcPhone:UpdateALL_SIM', xPlayer.source, phoneNumber)
            else
                MySQL.Async.execute(
                    'UPDATE users SET phone_number = NULL WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 0 WHERE number = @phone_number',
                    {
                        ['@phone_number'] = phoneNumber
                    }
                    )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~r~Dezaktywowano karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, '')
            end
        end
    end)
end)

RegisterServerEvent('watykan_sim:dropSIM')
AddEventHandler('watykan_sim:dropSIM', function(itemLabel)
    local phoneNumber = string.sub(itemLabel, 14)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier AND `number` = @sim', {
        ['@identifier'] = xPlayer.identifier,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            if sim[1].used == '0' then
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = NULL WHERE number = @number',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Wyrzucono karte SIM: #' .. phoneNumber, 5000, 'primary')
            else
                MySQL.Async.execute(
                    'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = ''
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = NULL WHERE number = @number',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 0 WHERE number = @number',
                    {
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~r~Dezaktywowano karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, '')
            end
        end
    end)
end)

ESX.RegisterServerCallback('OsloRP:getMoney', function(source, cb)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    money = xPlayer.getMoney()
    cb(money)
end)

RegisterServerEvent('OsloRP:buySim')
AddEventHandler('OsloRP:buySim', function()

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  local num = getPhoneRandomNumber()
  xPlayer.removeMoney(1000)
  MySQL.Async.fetchAll(
    'SELECT * FROM user_sim WHERE number = @sim',
    {
        ['@sim'] = num
    },
    function(result)
        if result ~= nil then
            if #result > 0 then
                TriggerEvent('OsloRP:buySim')
            else
                MySQL.Async.execute(
                    'INSERT INTO `user_sim` (`identifier`, `number`, `label`, `owner`) VALUES (@identifier, @phone_number, @label, @identifier)',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = num,
                        ['@label'] = 'Karta SIM - #' .. num,      
                    }
                )
                TriggerClientEvent("FeedM:showAdvancedNotification", xPlayer.source, 'Arctic Mobile', 'Zakup', '~g~Pomyślnie zakupiono Karte SIM #' .. num, 'CustomLogo', 5000, 'primary')
            end
        else
            MySQL.Async.execute(
                'INSERT INTO `user_sim` (`identifier`, `number`, `label`, `owner`) VALUES (@identifier, @phone_number, @label, @identifier)',
                {
                    ['@identifier']   = xPlayer.identifier,
                    ['@phone_number'] = num,
                    ['@label'] = 'Karta SIM - #' .. num,      
                }
            )
            TriggerClientEvent("FeedM:showAdvancedNotification", xPlayer.source, 'Arctic Mobile', 'Zakup', '~g~Pomyślnie zakupiono Karte SIM #' .. num, 'CustomLogo', 5000, 'primary')
        end
  end )
end)

function getPhoneRandomNumber()
    local numBase = math.random(1000000,9999999)
    num = string.format("%07d", numBase)
	return num
end

ESX.RegisterServerCallback('OsloRP:getCount', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll(
      'SELECT * FROM user_sim WHERE owner = @identifier',
      {
          ['@identifier'] = xPlayer.identifier
      },
      function(result)
        cb(#result)
    end )
end)

ESX.RegisterServerCallback('OsloRP:getSims', function(source, cb, player)
	local elements = {}
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(player)
	MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier ', {
		['@identifier'] = xPlayer.identifier
	}, function(sim)
		cb(sim)
	end)
end)

ESX.RegisterServerCallback('OsloRP:getPlayerSims', function(source, cb, player)
	local elements = {}
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(player)
	MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `owner` = @identifier ', {
		['@identifier'] = xPlayer.identifier
    }, function(sim)

		cb(sim)
	end)
end)

ESX.RegisterServerCallback('OsloRP:getPropertySims', function(source, cb, property)
	local elements = {}
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `owner` = @identifier AND `property` = @property', {
        ['@identifier'] = xPlayer.identifier,
        ['@property'] = property
	}, function(sim)
		cb(sim)
	end)
end)

RegisterServerEvent('OsloRP:duplicateSim')
AddEventHandler('OsloRP:duplicateSim', function(sim)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() > 299 then
        MySQL.Async.execute(
        'UPDATE user_sim SET identifier = @identifier, property = NULL WHERE number = @phone_number',
            {
                ['@identifier']   = xPlayer.identifier,
                ['@phone_number'] = sim
            }
        )
        TriggerClientEvent("FeedM:showAdvancedNotification", xPlayer.source, 'Arctic Moblie', 'Zakup', '~g~Pomyślnie otrzymano duplikat Karty SIM #' .. sim, 'CustomLogo', 5000, 'primary')
    else
        TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~r~Nie masz tyle pieniędzy przy sobie!', 5000, 'primary')
    end
end)

RegisterServerEvent('OsloRP:deleteSim')
AddEventHandler('OsloRP:deleteSim', function(sim)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.execute(
        'DELETE FROM `user_sim` WHERE number = @sim',
        {
            ['@sim'] = sim,
        }
    )
    TriggerClientEvent("FeedM:showAdvancedNotification", xPlayer.source, 'Arctic Mobile', 'Rozwiązanie Umowy', '~g~Pomyślnie usunięto Karte SIM #' .. sim, 'CustomLogo', 5000, 'primary')
end)

RegisterServerEvent('watykan_sim:giveSIM')
AddEventHandler('watykan_sim:giveSIM', function(target, itemLabel)
    local phoneNumber = string.sub(itemLabel, 14)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier AND `number` = @sim', {
        ['@identifier'] = xPlayer.identifier,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            if sim[1].used == '0' then
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = @identifier WHERE number = @number',
                    {
                        ['@identifier']   = tPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Oddałeś karte SIM: #' .. phoneNumber,'CustomLogo', 5000, 'primary')
                TriggerClientEvent("FeedM:showNotification", tPlayer.source, '~g~Otrzymałeś karte SIM: #' .. phoneNumber, 'CustomLogo', 5000, 'primary')
            else
                MySQL.Async.execute(
                    'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = ''
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = @identifier WHERE number = @number',
                    {
                        ['@identifier']   = tPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 0 WHERE number = @number',
                    {
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~r~Dezaktywowano karte SIM: #' .. phoneNumber, 'CustomLogo', 5000, 'primary')
                TriggerClientEvent("FeedM:showNotification", tPlayer.source, '~g~Otrzymałeś karte SIM: #' .. phoneNumber, 'CustomLogo', 5000, 'primary')
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source,  '')
            end
        end
    end)
end)

RegisterServerEvent('watykan_sim:giveSIM')
AddEventHandler('watykan_sim:giveSIM', function(target, itemLabel)
    local phoneNumber = string.sub(itemLabel, 14)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier AND `number` = @sim', {
        ['@identifier'] = xPlayer.identifier,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            if sim[1].used == '0' then
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = @identifier WHERE number = @number',
                    {
                        ['@identifier']   = tPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Oddałeś karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerClientEvent("FeedM:showNotification", tPlayer.source, '~g~Otrzymałeś karte SIM: #' .. phoneNumber, 5000, 'primary')
            else
                MySQL.Async.execute(
                    'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = ''
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = @identifier WHERE number = @number',
                    {
                        ['@identifier']   = tPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 0 WHERE number = @number',
                    {
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~r~Dezaktywowano karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerClientEvent("FeedM:showNotification", tPlayer.source, '~g~Otrzymałeś karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, '')
            end
        end
    end)
end)

RegisterServerEvent('watykan_sim:putHouseSIM')
AddEventHandler('watykan_sim:putHouseSIM', function(itemLabel, property)
    local phoneNumber = string.sub(itemLabel, 14)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier AND `number` = @sim', {
        ['@identifier'] = xPlayer.identifier,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            if sim[1].used == '0' then
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = NULL, property = @property WHERE number = @number',
                    {
                        ['@property'] = property,
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Oddłożyłeś karte SIM: #' .. phoneNumber, 5000, 'primary')
            else
                MySQL.Async.execute(
                    'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
                    {
                        ['@identifier']   = xPlayer.identifier,
                        ['@phone_number'] = ''
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = NULL WHERE number = @number',
                    {
                        ['@number'] = phoneNumber
                    }
                )
                MySQL.Async.execute(
                    'UPDATE user_sim SET used = 0, property = @property WHERE number = @number',
                    {
                        ['@number'] = phoneNumber,
                        ['@property'] = property
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~r~Dezaktywowano karte SIM: #' .. phoneNumber, 5000, 'primary')
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, '')
            end
        end
    end)
end)

RegisterServerEvent('watykan_sim:getHouseSIM')
AddEventHandler('watykan_sim:getHouseSIM', function(itemLabel, property)

    local phoneNumber = string.sub(itemLabel, 14)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `number` = @sim AND `property` = @property', {
        ['@property'] = property,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            if sim[1].used == '0' and sim[1].property ~= nil then
                MySQL.Async.execute(
                    'UPDATE user_sim SET identifier = @identifier, property = NULL WHERE number = @number',
                    {
                        ['@identifier'] = xPlayer.identifier,
                        ['@number'] = phoneNumber
                    }
                )
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Wyciągnąłeś karte SIM: #' .. phoneNumber, 5000, 'primary')
            end
        end
    end)
end)

RegisterServerEvent('watykan_sim:joinAcitvate')
AddEventHandler('watykan_sim:joinAcitvate', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM `user_sim` WHERE `identifier` = @identifier AND `used` = 1', {
        ['@identifier'] = xPlayer.identifier,
        ['@sim'] = phoneNumber
    }, function(sim)
        if sim ~= nil then
            if sim[1] ~= nil then
                TriggerClientEvent("FeedM:showNotification", xPlayer.source, '~g~Aktyowowano karte SIM: #' .. sim[1].number, 5000, 'primary') 
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, sim[1].number)
            else
                TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, '')
            end
        else
            TriggerEvent("gcPhone:UpdateALL_SIM", xPlayer.source, '')
        end
    end)
end)

RegisterServerEvent('W Pack 1.0RP:sendDMG')
AddEventHandler('WhipeRP:sendDMG', function(data)
    local connect = {
        {
            ["color"] = "39840",
            ["title"] = "DMG BOOST",
            ["description"] = data,
            ["footer"] = {
            ["text"] = "NeeY",
            },
        }
    }
    
PerformHttpRequest("", function(err, text, headers) end, 'POST', json.encode({username = "[LOGI]", embeds = connect}), { ['Content-Type'] = 'application/json' })
end)