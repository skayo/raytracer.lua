local math = math
local class = require('lib.class')
local material = require('lib.base.material')

---Get the Schlick's approximation for reflectance
---@param cosine number
---@param ref_idx number
---@return number
---@nodiscard
local function reflectance(cosine, ref_idx)
	local r0 = (1 - ref_idx) / (1 + ref_idx) ---@type number
	r0 = r0 * r0
	return r0 + (1 - r0) * ((1 - cosine) ^ 5)
end


---Represents a dielectric material (e.g. glass)
---@class dielectric : material
---@overload fun(index_of_refraction: number): dielectric
---@field index_of_refraction number
local dielectric = class(material)

---Init the material
---@param index_of_refraction number The retractive index (typically air = 1.0, glass = 1.3–1.7, diamond = 2.4)
function dielectric:new(index_of_refraction)
	self.index_of_refraction = index_of_refraction
end

---Scatter and color a ray that hits the material
---@param r_in ray
---@param rec hit_record
---@param attenuation color
---@param scattered ray
---@return boolean
function dielectric:scatter(r_in, rec, attenuation, scattered)
	attenuation:set(1, 1, 1)
	local refraction_ratio = rec.front_face and (1 / self.index_of_refraction) or self.index_of_refraction

	local unit_direction = r_in.direction:unit_vector()
	local cos_theta = math.min((-unit_direction):dot(rec.normal), 1)
	local sin_theta = math.sqrt(1 - cos_theta * cos_theta)

	local cannot_refract = refraction_ratio * sin_theta > 1

	local direction ---@type vec3
	if cannot_refract or reflectance(cos_theta, refraction_ratio) > math.random() then
		direction = unit_direction:reflect(rec.normal)
	else
		direction = unit_direction:refract(rec.normal, refraction_ratio)
	end

	scattered:set(rec.p, direction, r_in.time)
	return true
end

return dielectric
