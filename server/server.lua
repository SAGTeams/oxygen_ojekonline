local QBCore = exports['qb-core']:GetCoreObject()

-- Variabel untuk cooldown dan tracking
local paymentCooldown = {}
local lastPayments = {}

RegisterServerEvent('oxygen_ojekonline:server:masukkanmotor')
AddEventHandler('oxygen_ojekonline:server:masukkanmotor', function(plate, model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
end)

RegisterServerEvent('oxygen_ojekonline:server:bayar')
AddEventHandler('oxygen_ojekonline:server:bayar', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Cek dasar
    if not Player then return end
    if not src then return end
    
    -- Validasi amount
    if type(amount) ~= "number" then
        print(("[EXPLOIT] Player %s (%s) mencoba menggunakan amount tidak valid: %s"):format(
            Player.PlayerData.name,
            Player.PlayerData.citizenid,
            json.encode(amount)
        ))
        DropPlayer(src, "Aksi tidak diizinkan")
        return
    end
    
    -- Cek range payment yang valid
    local minPayment = Config.PaymentRange[1]
    local maxPayment = Config.PaymentRange[2]
    
    if amount < minPayment or amount > maxPayment then
        print(("[EXPLOIT] Player %s (%s) mencoba memodifikasi payment amount: %s"):format(
            Player.PlayerData.name,
            Player.PlayerData.citizenid,
            amount
        ))
        DropPlayer(src, "Aksi tidak diizinkan")
        return
    end
    
    -- Cooldown system (5 detik)
    local currentTime = os.time()
    if paymentCooldown[src] and currentTime - paymentCooldown[src] < 5 then
        print(("[EXPLOIT] Player %s (%s) mencoba spam payment"):format(
            Player.PlayerData.name,
            Player.PlayerData.citizenid
        ))
        return
    end
    paymentCooldown[src] = currentTime
    
    -- Tracking payment pattern
    lastPayments[src] = lastPayments[src] or {}
    table.insert(lastPayments[src], {
        amount = amount,
        time = currentTime
    })
    
    -- Cek pattern payment yang mencurigakan
    if #lastPayments[src] > 3 then
        local total = 0
        for _, payment in ipairs(lastPayments[src]) do
            total = total + payment.amount
        end
        
        -- Jika dapat lebih dari 3x maxPayment dalam 30 detik
        if total > (maxPayment * 3) and (currentTime - lastPayments[src][1].time) < 30 then
            print(("[EXPLOIT] Player %s (%s) terdeteksi pola payment mencurigakan: %s dalam %s detik"):format(
                Player.PlayerData.name,
                Player.PlayerData.citizenid,
                total,
                (currentTime - lastPayments[src][1].time)
            ))
            DropPlayer(src, "Aksi tidak diizinkan")
            return
        end
        
        -- Hapus data lama
        if #lastPayments[src] > 10 then
            table.remove(lastPayments[src], 1)
        end
    end
    
    -- Jika semua validasi lolos, berikan payment
    Player.Functions.AddMoney('cash', amount)
    TriggerClientEvent('QBCore:Notify', src, 'Kamu mendapatkan $'..amount..' dari mengantar penumpang', 'success')
    
    -- Log payment yang valid
    print(("[PAYMENT] Player %s (%s) menerima payment dari mengantar penumpang: $%s"):format(
        Player.PlayerData.name,
        Player.PlayerData.citizenid,
        amount
    ))
end)

-- Fungsi untuk reset cooldown saat player disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    paymentCooldown[src] = nil
    lastPayments[src] = nil
end)

QBCore.Functions.CreateCallback('oxygen_ojekonline:server:CheckMotor', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local ped = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        local model = GetEntityModel(vehicle)
        local isMotor = false
        
        for _, motorModel in ipairs(Config.MotorModels) do
            if model == GetHashKey(motorModel) then
                isMotor = true
                break
            end
        end
        
        cb(isMotor)
    else
        cb(false)
    end
end)