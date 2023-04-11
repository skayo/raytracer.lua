local class = require('lib.class')
local vec3 = require('lib.vec3')
local ray = require('lib.ray')
local utils = require('lib.utils')

---Represents the camera
---@class camera
---@overload fun(): camera
---@field origin point3
---@field lower_left_corner point3
---@field horizontal vec3
---@field vertical vec3
---@field u vec3
---@field v vec3
---@field w vec3
---@field lens_radius number
local camera = class()

---Init the camera
---@param lookfrom point3
---@param lookat point3
---@param vup vec3
---@param vfov number Vertical field-of-view in degrees
---@param aspect_ratio number
---@param aperture number
---@param focus_dist number
function camera:new(lookfrom, lookat, vup, vfov, aspect_ratio, aperture, focus_dist)
	local theta = utils.degrees_to_radians(vfov)
	local h = math.tan(theta / 2)
	local viewport_height = 2.0 * h
	local viewport_width = aspect_ratio * viewport_height

	self.w = (lookfrom - lookat):unit_vector()
	self.u = vup:cross(self.w):unit_vector()
	self.v = self.w:cross(self.u)

	self.origin = lookfrom
	self.horizontal = focus_dist * viewport_width * self.u
	self.vertical = focus_dist * viewport_height * self.v
	self.lower_left_corner = self.origin - self.horizontal / 2 - self.vertical / 2 - focus_dist * self.w

	self.lens_radius = aperture / 2
end

---Get a ray from the camera
---@param s number
---@param t number
---@return ray
---@nodiscard
function camera:get_ray(s, t)
	local rd = vec3.random_in_unit_disk() * self.lens_radius
	local offset = self.u * rd.x + self.v * rd.y

	return ray(
		self.origin + offset,
		self.lower_left_corner + self.horizontal * s + self.vertical * t - self.origin - offset
	)
end

return camera
