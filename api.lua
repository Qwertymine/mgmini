local function scale_noise(noise,scale)
	noise = table.copy(noise)
	local s = noise.spread
	s.x = s.x / scale.x
	s.z = s.z / scale.z

	if noise.dims
	and noise.dims == 2 then
		s.y = s.y / scale.z
		noise.scale = noise.scale / scale.y
	else
		s.y = s.y / scale.y
	end

	return noise
end

local function smallest_octave_scale(noise)
	if (noise.lacunarity or 2) < 1 then
		return noise.spread
	end

	local weight = math.pow((1/(noise.lacunarity or 2.0)),(noise.octaves or 1)-1)

	return vector.multiply((noise.spread or {x=0,y=0,z=0}),weight)
end

local function average_value(noise)
	if not string.match(noise.flags or "",".absvalue.") then
		return noise.offset or 0
	end

	local weight = 0
	for i=1,(noise.octaves or 0) do
		weight = weight + math.pow((noise.persistance or 0),i-1)
	end

	return (noise.offset or 0) + (weight * (noise.scale or 0))
end

local function minify_function(func,scale)
	return function(noise,map_size)
		if type(noise) ~= "table" then
			minetest.log("error","Old format defintions are not supported")
			error()
		end

		local snoise = scale_noise(noise,scale)
		local nscale = smallest_octave_scale(snoise)
		if nscale.x < 1
		or nscale.y < 1
		or nscale.z < 1 then
			if snoise.lacunarity > 1
			and snoise.occtaves > 1 then
				snoise.octaves = 1
				nscale = smallest_octave_scale(snoise)
				if nscale.x < 1
				or nscale.y < 1
				or nscale.z < 1 then
					snoise = mgmini.ave_val_def(average_value(noise))
				end
			else
				snoise = mgmini.ave_val_def(average_value(noise))
			end
		end

		return func(snoise,map_size)
	end
end

	
local minified = false
local miniscale = nil
mgmini.minify = function(self,scale)
	if minified then
		return miniscale
	end

	minetest.get_perlin_map = minify_function(minetest.get_perlin_map,scale)
	PerlinNoiseMap = minify_function(PerlinNoiseMap,scale)
	minetest.get_perlin = minify_function(minetest.get_perlin,scale)
	PerlinNoise = minify_function(PerlinNoise,scale)

	minified = true
	miniscale = scale
	return miniscale
end
	
