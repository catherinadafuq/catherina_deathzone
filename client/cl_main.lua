ESX = exports['es_extended']:getSharedObject()

local deathZone = Config.DeathZone
local respawnLocation = Config.RespawnLocation
local respawnTime = Config.RespawnTime

function isPlayerInDeathZone(playerPed)
    local playerPos = GetEntityCoords(playerPed)
    local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, deathZone.x, deathZone.y, deathZone.z)
    return distance <= deathZone.radius
end

RegisterNetEvent('playerDied')
AddEventHandler('playerDied', function()
    local playerPed = PlayerPedId()
    if isPlayerInDeathZone(playerPed) then
        exports['mythic_progbar']:Progress({
            name = "respawn_progress",
            duration = respawnTime,
            label = "Respawning...",
            useWhileDead = true,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "missheistfbi3b_ig7",
                anim = "loop_m_ped_dead_loop",
            },
            prop = {},
        }, function(status)
            if not status then
                ResurrectPed(playerPed)
                SetEntityCoords(playerPed, respawnLocation.x, respawnLocation.y, respawnLocation.z, 0, 0, 0, false)
                TriggerEvent('esx_ambulancejob:revive')
                Citizen.Wait(1000)
                SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if IsEntityDead(PlayerPedId()) then
            TriggerEvent('playerDied')
            Citizen.Wait(5000)
        end
    end
end)
