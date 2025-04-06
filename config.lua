Config = {}

Config.DrawDistance = 20.0  --marker draw distance


Config.ImpoundCost = 3000

Config.allowEdit = true     --allow players to edit the label and pictures in the garage page

Config.SeperateGarage = true

Config.retrieveVerify = true    --prevent duplicated vehicles

Config.trimPlate = true

Config.TextUI = function(text)
    local isOpen, current_text = lib.isTextUIOpen()
    if not isOpen then
        lib.showTextUI(text, {
            icon = 'car',
            style = {
                borderRadius = 0.2,
                backgroundColor = '#BB2649',
                color = 'white'
            }
        })
    end
end

Config.CloseUI = function()
    lib.hideTextUI()
end

Config.notify = function(msg, type)
    lib.notify({
        title = msg,
        type = type
    })
end

Config.Markers = {
	EntryPoint = {
		Type = 27,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 187,
			g = 38,
			b = 73,
		},
	},
	StopPoint = {
		Type = 27,
		Size = {
			x = 2.0,
			y = 2.0,
			z = 0.5,
		},
		Color = {
			r = 187,
			g = 38,
			b = 73,
		},
	},
	GetOutPoint = { 
		Type = 27,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 187,
			g = 38,
			b = 73,
		},
	},
}

Config.impoundState = { --set this to false if you don't want to modify the vehicle state when retrieve from impound
    fuel = 20.0,
    bodyHealth = 500.0,
    engineHealth = 500.0
}

Config.specialType = {  --vehicle types to be excluded from the default garage (without setting type in  Config.Garages)
    ['heli'] = true,
    ['boat'] = true,
    ['plane'] = true,
    ['submarine'] = true,
    ['trailer'] = true,
    ['train'] = true
}

Config.Garages = {
    --garages
	['VespucciBoulevard'] = {
        coords = {
            EntryPoint = vec(-285.2, -886.5, 31.0),
            StopPoint = vec(-302.35, -899.31, 31.0),
        },
        SpawnPoint = vec(-309.3, -897.0, 31.0, 351.8),
		blip = {
            Coords = vec(-285.2, -886.5, 31.0),
            Enable = true,
            Sprite = 357,
		    Scale = 0.8,
		    Colour = 3,
            Text = 'Garage'
        }
	},
	['SanAndreasAvenue'] = {
        coords = {
            EntryPoint = vec(216.57, -809.83, 30.8),
            StopPoint = vec(216.4, -786.6, 30.8),
        },
        SpawnPoint = vec(230.09, -798.7, 30.8, 158.8),
		blip = {
            Coords = vec(216.57, -809.83, 30.8),
            Enable = true,
            Sprite = 357,
		    Scale = 0.8,
		    Colour = 3,
            Text = 'Garage'
        }
	},
    
	['SanAndreasAvenueHeli'] = {
        coords = {
            EntryPoint = vec(239.0495, -754.4442, 34.6361),
            StopPoint = vec(248.0409, -752.0583, 34.6365),
        },
        SpawnPoint = vec(248.0409, -752.0583, 34.6365, 255.8543),
		blip = {
            Coords = vec(239.0495, -754.4442, 34.6361),
            Enable = true,
            Sprite = 357,
		    Scale = 0.8,
		    Colour = 3,
            Text = 'Garage'
        },
        type = 'heli',
        size = 10.0
	},

    
	['ambulance'] = {
        coords = {
            EntryPoint = vec(283.2337, -612.9584, 43.3368),
            StopPoint = vec(289.6236, -610.9771, 43.3774),
        },
        SpawnPoint = vec(289.6236, -610.9771, 43.3774, 21.4088),
		blip = {
            Coords = vec(239.0495, -754.4442, 34.6361),
            Enable = false,
            Sprite = 357,
		    Scale = 0.8,
		    Colour = 3,
            Text = 'Garage'
        },
        job = 'ambulance',  --retrict players with this job to access the garage
        job_garage = 'ambulance',   --retrieve the vehicles of this job
        size = 10.0
	},
	
    --impounds
    ['LosSantos'] = {
        coords = {
            GetOutPoint = vec(400.7, -1630.5, 29.3)
        },
		SpawnPoint = vec(404.2541, -1643.5513, 29.2919, 222.4407),
        blip = {
            Coords = vec(400.7, -1630.5, 29.3),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound'
        }
	},
    ['LosSantosJob'] = {
        coords = {
            GetOutPoint = vec(375.72, -1618.96, 29.29)
        },
		SpawnPoint = vec(393.78, -1618.83, 29.2, 323.3),
        blip = {
            Coords = vec(375.72, -1618.96, 29.29),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound (job)'
        },
        isJob = true
	},
	['PaletoBay'] = {
        coords = {
            GetOutPoint = vec(-211.4, 6206.5, 31.4)
        },
		SpawnPoint = vec(-204.6, 6221.6, 30.5, 227.2),
		blip = {
            Coords = vec(-211.4, 6206.5, 31.4),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound'
        }
	},
	['SandyShores'] = {
        coords = {
            GetOutPoint = vec(1645.23, 3807.01, 35.12)
        },
		SpawnPoint = vec(1643.63, 3801.42, 35.01, 142.66),
		blip = {
            Coords = vec(1645.23, 3807.01, 35.12),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound'
        }
	},
}