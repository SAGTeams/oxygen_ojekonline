local QBCore = exports['qb-core']:GetCoreObject()
local hasPassenger = false
local passenger = nil
local destination = nil
local blip = nil
local ojekPed = nil
local ojekLocation = nil
local isOjekActive = false
local startJobPed = nil
local SpawnVehicle = false

-- Buat NPC untuk memulai job
function CreateStartJobNPC()
    QBCore.Functions.LoadModel(Config.StartJobPed)
    
    startJobPed = CreatePed(4, GetHashKey(Config.StartJobPed), Config.StartJobLocation.x, Config.StartJobLocation.y, Config.StartJobLocation.z - 1.0, Config.StartJobLocation.w or 0.0, false, true)
    FreezeEntityPosition(startJobPed, true)
    SetEntityInvincible(startJobPed, true)
    SetBlockingOfNonTemporaryEvents(startJobPed, true)
    
    exports['qtarget']:AddTargetEntity(startJobPed, {
        options = {
            {
                type = "client",
                event = "ojek:openMenu",
                icon = "fas fa-motorcycle",
                label = "Buka Layanan Ojek"
            }
        },
        distance = 2.5
    })
end

-- Menu untuk memulai job ojek
RegisterNetEvent('ojek:openMenu', function()
    local menu = {
        {
            header = "OJEK ONLINE | JOB",
            icon = "fas fa-motorcycle",
            txt = "",
            isMenuHeader = true
        },
        {
            header = "Mulai Layanan",
            txt = "Aktifkan layanan ojek",
            icon = "fas fa-motorcycle",
            params = {
                event = "oxygen_ojekonline:client:toggleJob",
                args = {
                    active = true
                }
            }
        },
        {
            header = "Hentikan Layanan",
            icon = "fas fa-stopwatch",
            txt = "Nonaktifkan layanan ojek",
            params = {
                event = "oxygen_ojekonline:client:toggleJob",
                args = {
                    active = false
                }
            }
        },
        {
            header = "Tutup Menu",
            icon = "fa-solid fa-arrow-left",
            txt = "",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }
    
    exports['oxygen_menu']:openMenu(menu)
end)

-- Toggle job ojek
RegisterNetEvent('oxygen_ojekonline:client:toggleJob', function(data)
    isOjekActive = data.active
    
    if isOjekActive then
        QBCore.Functions.Notify('Layanan ojek aktif! Penumpang akan muncul di map.', 'success')
        CreateOjekNPC()
        TriggerEvent('oxygen_ojekonline:gantibaju')
        TriggerEvent('oxygen_ojekonline:client:spawnmotor')
        exports.oxygen_ui:Show("OJEK ONLINE", "Antar dan jemput penumpang anda untuk mendapatkan uang")
    else
        QBCore.Functions.Notify('Layanan ojek dihentikan.', 'error')
        TriggerEvent("illenium-appearance:client:reloadSkin")
        TriggerEvent('oxygen_ojekonline:client:masukkanmotor')
        exports.oxygen_ui:Close()
        if DoesEntityExist(ojekPed) then
            DeleteEntity(ojekPed)
        end
        if blip then
            RemoveBlip(blip)
            blip = nil
        end
        hasPassenger = false
        passenger = nil
    end
end)

-- fungsi spawn kendaraan
RegisterNetEvent('oxygen_ojekonline:client:spawnmotor', function(data)
    local model = Config.MotorModels[1]
    local player = PlayerPedId()
    QBCore.Functions.SpawnVehicle(model, function(vehicle)
        SetEntityHeading(vehicle, Config.HeadingSpawnMotor)
        SetVehicleNumberPlateText(vehicle, Config.PlateMotor..tostring(math.random(1000, 9999)))
        TaskWarpPedIntoVehicle(player, vehicle, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
        SetVehicleEngineOn(vehicle, true, true)
        SpawnVehicle = true
        exports['cdn-fuel']:SetFuel(vehicle, 100.0)
    end, Config.SpawnMotor , true)
    Wait(1000)
    local vehicle = GetVehiclePedIsIn(player, false)
    local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    vehicleLabel = GetLabelText(vehicleLabel)
end)

-- fungsi hapus kendaraan
RegisterNetEvent('oxygen_ojekonline:client:masukkanmotor')
AddEventHandler('oxygen_ojekonline:client:masukkanmotor', function()
    if SpawnVehicle then
        local Player = QBCore.Functions.GetPlayerData()
        QBCore.Functions.Notify("Berhasil mengembalikan kendaraan!", 'success', 5000)
        TriggerServerEvent('oxygen_ojekonline:server:masukkanmotor')
        local car = GetVehiclePedIsIn(PlayerPedId(), true)
        NetworkFadeOutEntity(car, true, false)
        Citizen.Wait(2000)
        QBCore.Functions.DeleteVehicle(car)
    else
        QBCore.Functions.Notify("Tidak ada kendaraan untuk dikembalikan!", 'error', 5000)
    end
    SpawnVehicle = false
end)

-- Fungsi untuk membuat NPC penumpang
function CreateOjekNPC()
    if not isOjekActive then return end
    
    local randomModel = Config.OjekModels[math.random(#Config.OjekModels)]
    local randomLoc = Config.OjekLocations[math.random(#Config.OjekLocations)]
    
    QBCore.Functions.LoadModel(randomModel)
    
    if DoesEntityExist(ojekPed) then
        DeleteEntity(ojekPed)
    end
    
    ojekPed = CreatePed(4, GetHashKey(randomModel), randomLoc.x, randomLoc.y, randomLoc.z - 1.0, 0.0, false, true)
    TaskStartScenarioInPlace(ojekPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    FreezeEntityPosition(ojekPed, true)
    SetEntityInvincible(ojekPed, true)
    SetBlockingOfNonTemporaryEvents(ojekPed, true)
    
    ojekLocation = randomLoc
    
    -- Buat blip di lokasi penumpang
    if blip then
        RemoveBlip(blip)
    end
    blip = AddBlipForCoord(randomLoc.x, randomLoc.y, randomLoc.z)
    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Penumpang Ojek")
    EndTextCommandSetBlipName(blip)
    
    -- Tambahkan target untuk mengambil penumpang
    exports['qtarget']:AddTargetEntity(ojekPed, {
        options = {
            {
                type = "client",
                event = "oxygen_ojekonline:client:takePassenger",
                icon = "fas fa-motorcycle",
                label = "Ambil Penumpang"
            }
        },
        distance = 2.5
    })
    
    QBCore.Functions.Notify('Ada penumpang menunggu di lokasi yang ditandai', 'primary', 5000)

    Wait(2000)
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = "OJEK ONLINE",
        subject = "Penumpang Baru",
        message = "Pak!.. Jemput saya di lokasi ini..!"
    })
    SetNewWaypoint(randomLoc.x, randomLoc.y)
end

-- Event untuk mengambil penumpang
RegisterNetEvent('oxygen_ojekonline:client:takePassenger', function()
    if hasPassenger then
        QBCore.Functions.Notify('Kamu sudah memiliki penumpang', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        QBCore.Functions.TriggerCallback('oxygen_ojekonline:server:CheckMotor', function(isMotor)
            if isMotor then
                -- Masukkan NPC ke motor sebagai penumpang
                ClearPedTasksImmediately(ojekPed)
                FreezeEntityPosition(ojekPed, false)
                
                local seat = -1
                if GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) > 1 then
                    seat = 0  -- Seat penumpang pertama
                end
                
                TaskEnterVehicle(ojekPed, vehicle, -1, seat, 2.0, 1, 0)
                
                local timeout = 0
                while not IsPedInVehicle(ojekPed, vehicle, false) and timeout < 50 do
                    Wait(1000)
                    timeout = timeout + 1
                end
                
                if IsPedInVehicle(ojekPed, vehicle, false) then
                    -- Set tujuan random
                    local randomDest = Config.OjekLocations[math.random(#Config.OjekLocations)]
                    while #(randomDest - ojekLocation) < 100.0 do
                        randomDest = Config.OjekLocations[math.random(#Config.OjekLocations)]
                    end
                    
                    destination = randomDest
                    hasPassenger = true
                    passenger = ojekPed
                    
                    SetPedKeepTask(ojekPed, true)
                    SetBlockingOfNonTemporaryEvents(ojekPed, true)
                    
                    -- Update blip
                    if blip then
                        RemoveBlip(blip)
                    end
                    blip = AddBlipForCoord(destination.x, destination.y, destination.z)
                    SetBlipSprite(blip, Config.BlipSprite)
                    SetBlipColour(blip, 2)
                    SetBlipRoute(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Tujuan Penumpang")
                    EndTextCommandSetBlipName(blip)
                    
                    QBCore.Functions.Notify('Antarkan penumpang ke lokasi yang ditandai', 'primary', 5000)
                    
                    -- Hapus target dari NPC
                    exports['qtarget']:RemoveTargetEntity(ojekPed, nil)
                else
                    QBCore.Functions.Notify('Penumpang gagal naik ke motor', 'error')
                end
            else
                QBCore.Functions.Notify('Kamu harus menggunakan motor yang sudah terdaftar di perusahaan untuk mengangkut penumpang', 'error')
            end
        end)
    else
        QBCore.Functions.Notify('Kamu harus berada di dalam kendaraan', 'error')
    end
end)

-- Fungsi untuk menurunkan penumpang
function DropPassenger()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if hasPassenger and DoesEntityExist(passenger) then
        local vehPos = GetEntityCoords(vehicle or ped)
        if #(vehPos - destination) < 20.0 then
            if vehicle and IsPedInVehicle(passenger, vehicle, false) then
                TaskLeaveVehicle(passenger, vehicle, 0)
                
                local timeout = 0
                while IsPedInVehicle(passenger, vehicle, false) and timeout < 50 do
                    Wait(100)
                    timeout = timeout + 1
                end
            end
            
            local dropCoords = GetOffsetFromEntityInWorldCoords(vehicle or ped, 0.0, 1.0, 0.0)
            SetEntityCoords(passenger, dropCoords.x, dropCoords.y, dropCoords.z)
            TaskWanderStandard(passenger, 10.0, 10)
            
            local payment = math.random(Config.PaymentRange[1], Config.PaymentRange[2])
            TriggerServerEvent('oxygen_ojekonline:server:bayar', payment)
            
            hasPassenger = false
            if blip then
                RemoveBlip(blip)
                blip = nil
            end
            SetPedAsNoLongerNeeded(passenger)
            passenger = nil
            
            QBCore.Functions.Notify('Penumpang telah sampai di tujuan', 'success')
            
            -- Buat penumpang baru setelah beberapa detik
            if isOjekActive then
                Wait(10000)
                CreateOjekNPC()
            end
        else
            QBCore.Functions.Notify('Kamu belum sampai di tujuan penumpang', 'error')
        end
    end
end

-- Thread untuk memantau kendaraan
Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if hasPassenger then
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                QBCore.Functions.Notify('Penumpang kabur karena kamu meninggalkan motor!', 'error')
                if DoesEntityExist(passenger) then
                    ClearPedTasks(passenger)
                    TaskWanderStandard(passenger, 10.0, 10)
                    SetPedAsNoLongerNeeded(passenger)
                end
                if blip then
                    RemoveBlip(blip)
                end
                hasPassenger = false
                passenger = nil
                
                if isOjekActive then
                    Wait(10000)
                    CreateOjekNPC()
                end
            end
        end
    end
end)

-- Buat blip untuk lokasi awal job
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.StartJobLocation.x, Config.StartJobLocation.y, Config.StartJobLocation.z)
    SetBlipSprite(blip, Config.BlipNPC)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, Config.BlipColorNPC)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.NamaBlipNPC)
    EndTextCommandSetBlipName(blip)
end)

-- Inisialisasi
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CreateStartJobNPC()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if DoesEntityExist(startJobPed) then
            DeleteEntity(startJobPed)
        end
        if DoesEntityExist(ojekPed) then
            DeleteEntity(ojekPed)
        end
        if blip then
            RemoveBlip(blip)
        end
        exports['qtarget']:RemoveTargetEntity(startJobPed, nil)
        exports['qtarget']:RemoveTargetEntity(ojekPed, nil)
    end
end)

local function TombolTextUi(text)
    exports["oxygen_textui"]:showTextUI('turun', text, 'G')
end

local function TombolHilangkanTextui()
    exports["oxygen_textui"]:hideTextUI('turun')
end

-- Interaksi dengan penumpang
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        
        if hasPassenger then
            local vehPos = GetEntityCoords(GetVehiclePedIsIn(ped, false) or ped)
            if #(vehPos - destination) < 30.0 then
                TombolTextUi('Turunkan')
                if IsControlJustReleased(0, 47) then -- Tombol G
                    DropPassenger()
                    TombolHilangkanTextui()
                end
            end
        end
    end
end)

-- fungsi ganti baju ojek
RegisterNetEvent('oxygen_ojekonline:gantibaju', function()
    local gender = QBCore.Functions.GetPlayerData().charinfo.gender
    if gender == 0 then
            TriggerEvent('qb-clothing:client:loadOutfit', Config.BajuOjek.male)
    else
        TriggerEvent('qb-clothing:client:loadOutfit', Config.BajuOjek.female)
    end
end)