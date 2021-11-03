ESX = nil

local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

local HasAlreadyEnteredMarker = false
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	TriggerServerEvent('watykan_sim:joinAcitvate')
end)

Citizen.CreateThread(function()
	for i=1, #Config.SimCoords, 1 do
		local blip = AddBlipForCoord(Config.SimCoords[i].x, Config.SimCoords[i].y, Config.SimCoords[i].z)
		SetBlipSprite (blip, 459)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, 3)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('PLAY')
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(5)
		local coords = GetEntityCoords(GetPlayerPed(-1))
		for i=1, #Config.SimCoords, 1 do
			if(1 ~= -1 and GetDistanceBetweenCoords(coords, Config.SimCoords[i].x, Config.SimCoords[i].y, Config.SimCoords[i].z, true) < Config.DrawDistance) then
				DrawMarker(21, Config.SimCoords[i].x, Config.SimCoords[i].y, Config.SimCoords[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor .g, Config.MarkerColor .b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil
		for i=1, #Config.SimCoords, 1 do
			if(GetDistanceBetweenCoords(coords, Config.SimCoords[i].x, Config.SimCoords[i].y, Config.SimCoords[i].z, true) < Config.MarkerSize.x) then
				isInMarker  = true
				currentZone = k
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('watykan_sim:hasEnteredMarker')
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('watykan_sim:hasExitedMarker')
		end
	end
end)

AddEventHandler('watykan_sim:hasEnteredMarker', function()
	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = 'Wciśnij ~INPUT_CONTEXT~, aby otworzyć menu'
	CurrentActionData = {}
end)

AddEventHandler('watykan_sim:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			if IsControlPressed(0,  Keys['E']) then
				if CurrentAction == 'shop_menu' then
					OpenBuyMenu()
				end
				CurrentAction = nil
			end
		end
	end
end)

function OpenBuyMenu()
    local elements = {
      {label = 'Zakup karty SIM (1000$)',		value = 'b_sim'},
      {label = 'Zarządzanie kartami SIM',		value = 'z_sim'},
    }
  
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'sim_player',
      {
        title = "Arctic Mobile",
        align = 'center',
        elements	= elements
      },
      function(data, menu)
        if data.current.value == 'b_sim' then
          ESX.TriggerServerCallback('OsloRP:getMoney', function(money)
            if money > 999 then
              ESX.TriggerServerCallback('OsloRP:getCount', function(count)
                if count < 3 then
                  TriggerServerEvent('OsloRP:buySim')
                else
                  ESX.ShowNotification("~r~Osiągnieto limit kart SIM!")
                end
              end)
            else
              ESX.ShowNotification("~r~Nie masz wystarczającej liczby pieniędzy!")
            end
          end)
        end
        if data.current.value == 'z_sim' then
          ESX.TriggerServerCallback('OsloRP:getPlayerSims', function(sims)
            if #sims > 0 then
              local elements2 = {}
              for k,v in pairs(sims) do
                table.insert(elements2, { label = sims[k].label, value = sims[k].number })
              end
              ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'zsim_player',
                {
                  title = "Karty SIM",
                  align = 'center',
                  elements	= elements2
                },
                function(data2, menu2)
                  local elements3 = {
                    {label = 'Usuwanie karty SIM',	value = 'u_sim', sim = data2.current.value},
                    {label = 'Duplikat karty SIM (300$)',	value = 'd_sim', sim = data2.current.value},
                  }
                  ESX.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'msim_player',
                    {
                      title = "Karta SIM #" .. data2.current.value,
                      align = 'center',
                      elements	= elements3
                    },
                    function(data3, menu3)
                      if data3.current.value == 'u_sim' then
                        TriggerServerEvent('OsloRP:deleteSim', data3.current.sim)
                        menu3.close()
                        menu2.close()
                      end
                      if data3.current.value == 'd_sim' then
                        TriggerServerEvent('OsloRP:duplicateSim', data3.current.sim)
                        menu3.close()
                        menu2.close()
                      end
                    end,
                    function(data3,menu3)
                      menu3.close()
                    end
                  )
                end,
                function(data2,menu2)
                  menu2.close()
                end
              )
            else
              ESX.ShowNotification("~r~Nie posiadasz karty SIM!")
            end
          end, GetPlayerServerId(PlayerId()))
        end
      end,
      function(data,menu)
        menu.close()
      end
    )
  end

  local Abot = false

  RegisterNetEvent('esx_neey:BotOn')
  AddEventHandler('esx_neey:BotOn', function()
    if Abot == false then
      Abot = true
    else
      Abot = false
    end
  end)

  function getEntity(player)
    local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
    return entity
  end

  function ShootPlayer(player)
    local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
    SetPedShootsAtCoord(PlayerPedId(), head.x, head.y, head.z, true)
  end

--[[Citizen.CreateThread(
	function()
		while true do
      Citizen.Wait(0)
      if Abot then
        if IsControlPressed(0,  Keys['LEFTSHIFT']) then
          local Entity = IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
          local Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Entity)
          if Aiming then
            if IsEntityAPed(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
              if IsPlayerFreeAiming(PlayerId()) then
                local TargetPed = getEntity(PlayerId())
                local TargetPos = GetEntityCoords(TargetPed)
                local Exist = DoesEntityExist(TargetPed)
                local Dead = IsPlayerDead(TargetPed)

                if Exist and not Dead and IsEntityAPed(TargetPed) then
                    local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
                    if IsEntityVisible(TargetPed) and OnScreen then
                        if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 100000) then
                            local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
                            SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                            SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
                        end
                    end
                end
              end
            end
          end
        end
      end
    end
  end)]]--


  Data = {
    Weapons = {
      [`WEAPON_DBSHOTGUN`] = 8.0,
      [`WEAPON_SAWNOFFSHOTGUN`] = 3.5,
      [`WEAPON_PUMPSHOTGUN_MK2`] = 3.5,
      [`WEAPON_PUMPSHOTGUN`] = 3.5,
      [`WEAPON_BULLPUPSHOTGUN`] = 8.0
    },
  }
  

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local ped = PlayerPedId()
    local status, weapon = GetCurrentPedWeapon(ped, true)
    local aiming, shooting = IsControlPressed(0, 25), IsPedShooting(ped)
    local pid = PlayerId()
    if status == 1 and shooting then
      local curMul = GetPlayerWeaponDamageModifier(pid)
      if curMul > 1 then
        TriggerServerEvent('AxiRP:sendDMG', '**' .. GetPlayerName(pid) .. '** ma większy damage z broni niż powinien (Aktualny: ' .. curMul .. ', Dozwolony: 1, Bron: '.. weapon ..')' )
      end
    end
  end
end)