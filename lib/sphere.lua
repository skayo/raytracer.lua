local class = require('lib.class')
local hittable = require('lib.hittable')

---@class sphere : hittable
---@field center point3
---@field radius number
local sphere = class(hittable)

---@param center point3
---@param radius number
function sphere:new(center, radius)
	self.center = center
	self.radius = radius
end

---@param r ray
---@param t_min number
---@param t_max number
---@param rec hit_record
---@return boolean
function sphere:hit(r, t_min, t_max, rec)
	local oc = r.origin - self.center
	local a = r.direction:length_squared()
	local half_b = oc:dot(r.direction)
	local c = oc:length_squared() - self.radius*self.radius

	local discriminant = half_b*half_b - a*c
	if discriminant < 0 then return false end
	local sqrtd = math.sqrt(discriminant)

	local root = (-half_b - sqrtd) / a
	if root < t_min or t_max < root then
		root = (-half_b + sqrtd) / a
		if root < t_min or t_max < root then
			return false
		end
	end

	rec.t = root
	rec.p = r:at(rec.t)
	local outward_normal = (rec.p - self.center) / self.radius
	rec:set_face_normal(r, outward_normal)

	return true
end

return sphere