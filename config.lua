teleportPlayerIntoCar = true -- Should the player be teleported into the vehicle after spawning it?
blipRenderDistance = 150.0
interactDistance = 1.5
locations = {
    ['Mission Row Police Station'] = {
        coords = vec(458.81, -1017.5, 27.18), -- LOCATION OF THE BLIP
        parking_spots = {
            vector4(440.11, -1014.1, 28.76, 88.74)
            

        },
        vehicle_catagories = { -- MUST MATCH THE CATAGORIE NAMES BELOW
            'Police Community Support Officer',
            'Police Constable',
        },
        MarkerId = 1,
        MarkerSize = vec(1.0, 1.0, 1.5),
        Color = vec(0.0, 0.0, 255.0),
    },
    ['Davis Police Station'] = {
        coords = vec(357.03, -1591.02, 22.51), -- LOCATION OF THE BLIP
        parking_spots = {
		vector4(343.7198, -1608.266, 23.22245, 232.0012),
            	vector4(355.7184, -1579.304, 23.61763, 140.9581),
		vector4(341.3866, -1610.302, 23.22303, 231.2969),
		vector4(337.3654, -1615.448, 23.22304, 229.1078)


        },
        vehicle_catagories = { -- MUST MATCH THE CATAGORIE NAMES BELOW
        'Police Community Support Officer',
        'Police Constable',

        },
        MarkerId = 1,
        MarkerSize = vec(1.0, 1.0, 1.5),
        Color = vec(0.0, 0.0, 255.0),
    },
}

vehicle_list = {
    ['Police Community Support Officer'] = {
        acePerm = {'PCSO','ALL',},
        cars = {
            {'2019 Peugeot 3008', `police`}, -- Lable, MODELHash
            {'Mercedes Benz Sprinter Van', `fbi`},
        }
    },
    ['Police Constable'] = {
        acePerm = {'MPSERPT','ALL',},
        cars = {
            {'Mercedes Benz Sprinter Van ', `npt1`}, -- Lable, MODELHash
            {'2019 Peugeot 3008', `npt2`},
            
        }
    },
}