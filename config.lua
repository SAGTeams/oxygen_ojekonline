--░█████╗░██╗░░██╗██╗░░░██╗  ██████╗░███████╗██╗░░░██╗███████╗██╗░░░░░░█████╗░██████╗░███╗░░░███╗███████╗███╗░░██╗████████╗
--██╔══██╗╚██╗██╔╝╚██╗░██╔╝  ██╔══██╗██╔════╝██║░░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗████╗░████║██╔════╝████╗░██║╚══██╔══╝
--██║░░██║░╚███╔╝░░╚████╔╝░  ██║░░██║█████╗░░╚██╗░██╔╝█████╗░░██║░░░░░██║░░██║██████╔╝██╔████╔██║█████╗░░██╔██╗██║░░░██║░░░
--██║░░██║░██╔██╗░░░╚██╔╝░░  ██║░░██║██╔══╝░░░╚████╔╝░██╔══╝░░██║░░░░░██║░░██║██╔═══╝░██║╚██╔╝██║██╔══╝░░██║╚████║░░░██║░░░
--╚█████╔╝██╔╝╚██╗░░░██║░░░  ██████╔╝███████╗░░╚██╔╝░░███████╗███████╗╚█████╔╝██║░░░░░██║░╚═╝░██║███████╗██║░╚███║░░░██║░░░
--░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░  ╚═════╝░╚══════╝░░░╚═╝░░░╚══════╝╚══════╝░╚════╝░╚═╝░░░░░╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚══╝░░░╚═╝░░░

Config = {
    StartJobLocation = vector4(-267.27, -960.02, 31.22, 202.79), -- Lokasi awal untuk mulai job ojek
    BlipNPC = 226,
    BlipColorNPC = 5,
    NamaBlipNPC = "Pangkalan Ojek",  
    StartJobPed = 'a_m_m_fatlatin_01', -- Model NPC untuk mulai job
    BajuOjek = { -- baju ojek
        ['male'] = {
            outfitData = {
                ['t-shirt'] = {item = 2, texture = 0},
                ['torso2']  = {item = 37, texture = 1},
                ['arms']    = {item = 1, texture = 0},
                ['pants']   = {item = 24, texture = 6},
                ['shoes']   = {item = 7, texture = 2},
                ['accessory'] = {item = 203, texture = 0},
                ['hat'] = {item = 39, texture = 0},
            }
        },
        ['female'] = {
            outfitData = {
                ['t-shirt'] = {item = 14, texture = 0},
                ['torso2']  = {item = 22, texture = 0},
                ['arms']    = {item = 85, texture = 0},
                ['pants']   = {item = 47, texture = 4},
                ['shoes']   = {item = 98, texture = 1},
            }
        },
    },
    OjekLocations = { -- lokasi pengantaran
        vector3(253.93, -895.74, 28.11),
        vector3(1039.47, -740.69, 56.84),
        vector3(288.79, 179.19, 104.0),
        vector3(-627.70, 252.50, 80.63),
        vector3(-1614.37, -979.41, 13.02),
        vector3(-780.04, -1319.29, 5.00)
    },
    OjekModels = {
        'a_m_y_hipster_01',
        'a_m_y_business_01',
        'a_f_y_tourist_01',
        'a_m_y_beach_01',
        'a_f_y_business_02'
    },
    PaymentRange = {100, 500}, -- harga 1x pengantaran penumpang
    AntiExploit = { -- anti exploitasi uang
        MaxPaymentsPerMinute = 10, -- Maksimal 10 payment per menit
        PaymentCooldown = 5, -- Cooldown 5 detik antar payment
        KickThreshold = 3 -- Jika 3x melanggar, langsung kick
    },
    -- blips penumpang
    BlipSprite = 280,
    BlipColor = 5,
    MotorModels = { -- jenis kendaraan ojek
        'faggio',
    },
    SpawnMotor = vector3(-268.18, -987.93, 30.91), -- lokasi kendaraan ojek
    HeadingSpawnMotor = 247.82,
    PlateMotor = "OJEK"
}