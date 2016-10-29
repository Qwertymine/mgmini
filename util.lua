mgmini.zero_noise = {
	offset = 0,
	scale = 0,
	seed = 0,
	spread = {x=80,y=80,z=80},
	octaves = 1,
	persistance = 0.5,
	lacunarity = 1.5,
	--flags = nil,
}

mgmini.ave_val_def = function(value)
	local noise = table.copy(mgmini.zero_noise)
	noise.offset = value
	return noise
end
