local char = script.Parent
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {char}

local LJparams = RaycastParams.new()
LJparams.FilterType = Enum.RaycastFilterType.Exclude
LJparams.FilterDescendantsInstances = {char}

local TS = game:GetService("TweenService")

local canSlide = true

local canWaterSplash = true

function GPDust(pos)
	for i = 1, 20 do
		local dustpart = game:GetService("ReplicatedStorage").Effects.Meshes.IcoSphere:Clone()
		dustpart.Parent = workspace
		local size = (math.random(100,200)/100)
		dustpart.Position = Vector3.new(HRP.Position.X ,pos + (size/2), HRP.Position.Z)
		local tweenP = TS:Create(dustpart, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Vector3.new(dustpart.Position.X + (math.random(-800,800)/100), dustpart.Position.Y, dustpart.Position.Z + (math.random(-800,800)/100))})
		local tweenS = TS:Create(dustpart, TweenInfo.new(0.25), {Size = Vector3.new(size, size, size)})
		local tweenR = TS:Create(dustpart, TweenInfo.new(0.5), {Orientation = Vector3.new(math.random(0,180), math.random(0,180), math.random(0,180))})
		tweenP:Play()
		tweenS:Play()
		tweenR:Play()
		delay(0.25, function()
			local tweenS2 = TS:Create(dustpart, TweenInfo.new(0.25), {Size = Vector3.new(0, 0, 0)})
			tweenS2:Play()
		end)
		game.Debris:AddItem(dustpart, 0.5)
	end
end


while task.wait() do
	if canSlide == false and HRP.AssemblyLinearVelocity.Y < 0 then
		canSlide = true
	end
	
	if char:FindFirstChild("GP") then
		local GPparts = workspace:GetPartBoundsInBox(HRP.CFrame + Vector3.new(0,-4.2,0), Vector3.new(4,1,1))
		for i, v in pairs(GPparts) do
			if v.Name == "Crate" then
				GPDust(HRP.Position.Y - 2.8)
				local effect = game:GetService("ReplicatedStorage").Effects:FindFirstChild("Box_Break"):Clone()
				effect.CFrame = v.CFrame
				effect.Parent = workspace
				effect.Attachment.Planks:Emit(effect.Attachment.Planks:GetAttribute("EmitCount"))
				game.Debris:AddItem(effect, 1.5)
				v:Destroy()
			end
		end
	end
	
	local cannonRaycastResult = workspace:Raycast(HRP.Position, Vector3.new(0,-3,0), params)
	if char:FindFirstChild("Flipping") then
		if cannonRaycastResult and cannonRaycastResult.Instance then
			if cannonRaycastResult.Instance.Name == "Cannon" then return end
			HRP.AssemblyLinearVelocity = Vector3.zero
			char:FindFirstChild("Flipping"):Destroy()
			for i, v in pairs(animator:GetPlayingAnimationTracks()) do
				if v.Name == "Flipping" then
					v:Stop()
				end
			end
			game:GetService("SoundService"):WaitForChild("LandHeavy"):Play()
			hum:ChangeState("GettingUp")
			GPDust(cannonRaycastResult.Position.Y)
			hum.WalkSpeed = 0
			hum.JumpHeight = 0
			char:FindFirstChild("pCenter").Trail.Enabled = false
			task.wait(0.5)
			hum.WalkSpeed = 16
			hum.JumpHeight = 7.201
			hum.AutoRotate = true
		end
	end
	
	--Check Ground Pounds
	local raycastResult = workspace:Raycast(HRP.Position, Vector3.new(0,-4.2,0), params)
	
	if raycastResult and raycastResult.Instance then
		local canboost = true
		if raycastResult.Instance.Name == "BoostPad" then
			if canboost == true then
				HRP.AssemblyLinearVelocity = HRP.AssemblyLinearVelocity.Unit * raycastResult.Instance.Value.Value
			end
			canboost = false
		else
			canboost = true
		end
		if raycastResult.Instance.Name ~= "Water" then
			if char:FindFirstChild("InWater") then
				char:FindFirstChild("InWater"):Destroy()
			end
		else
			if not char:FindFirstChild("InWater") then
				local inwater = Instance.new("BoolValue", char)
				inwater.Name = "InWater"
			end
		end
		if raycastResult.Instance.Name == "Water" and canWaterSplash == true and HRP.AssemblyLinearVelocity.Magnitude > 5 then
			canWaterSplash = false
			local water = game:GetService("ReplicatedStorage").Effects:WaitForChild("WaterSplash"):Clone()
			water.Parent = workspace
			water.Position = raycastResult.Position + Vector3.new(0,0.1,0)
			water.Attachment.ParticleEmitter:Emit(1)
			game.Debris:AddItem(water, 1)
			delay(0.1, function()
				canWaterSplash = true
			end)
		end
	end
	
	
	
	
	if raycastResult and raycastResult.Instance and raycastResult.Instance.CanCollide == true then
		if raycastResult.Instance.Name == "Enemy" and raycastResult.Instance.Size == Vector3.new(4,4,4) then
			raycastResult.Instance.Size = Vector3.new(4,2,4)
			raycastResult.Instance.Position += Vector3.new(0,-2,0)
			HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X, 30, HRP.AssemblyLinearVelocity.Z)
			game.Debris:AddItem(raycastResult.Instance, 2)
		end
		--[[
		if not char:FindFirstChild("Slide") and not char:FindFirstChild("GP") and not char:FindFirstChild("GPLand") and HRP.AssemblyLinearVelocity.Y < -90 then
			local landImpact = game:GetService("ReplicatedStorage").Effects:WaitForChild("LandHighUp"):Clone()
			landImpact.Position = raycastResult.Position
			landImpact.Parent = workspace
			game.Debris:AddItem(landImpact, 0.5)
			for i, v in pairs(landImpact:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(v:GetAttribute("EmitCount"))
				end
			end
			task.wait()
			HRP.AssemblyLinearVelocity = Vector3.zero
			HRP.Anchored = true
			task.wait(1)
			HRP.Anchored = false
		end
		]]
		if raycastResult.Instance.Name == "Spring" then
			HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X, raycastResult.Instance:FindFirstChild("Power").Value, HRP.AssemblyLinearVelocity.Z)
			raycastResult.Instance.s1:Play()
			GPDust(raycastResult.Position.Y)
			raycastResult.Instance.Glow.Transparency = 0
			raycastResult.Instance.Glow.PointLight.Brightness = 5
			raycastResult.Instance.Glow.PointLight.Enabled = true
			local tweenT = TS:Create(raycastResult.Instance.Glow, TweenInfo.new(1), {Transparency = 1})
			tweenT:Play()
			local tweenB = TS:Create(raycastResult.Instance.Glow.PointLight, TweenInfo.new(1), {Brightness = 0})
			tweenB:Play()
			delay(1, function()
				raycastResult.Instance.Glow.PointLight.Enabled = false
			end)
			if not char:FindFirstChild("Slide") and not char:FindFirstChild("DiveCooldown") then
				hum:ChangeState("Jumping")
				canSlide = true
			else
				char:FindFirstChild("Slide").Value = false
				canSlide = false
			end
			delay(0.01, function()
				if char:FindFirstChild("GP") then
					char:FindFirstChild("GP"):Destroy()
				end
				if char:FindFirstChild("GPLand") then
					char:FindFirstChild("GPLand"):Destroy()
				end
				if char:FindFirstChild("LongJumpCD") then
					char:FindFirstChild("LongJumpCD"):Destroy()
					if HRP:FindFirstChild("LongJumpAO") then
						HRP:FindFirstChild("LongJumpAO"):Destroy()
					end
					for i, v in pairs(animator:GetPlayingAnimationTracks()) do
						if v.Name == "LongJump" then
							v:Stop()
						end
					end
				end
				for i, v in pairs(animator:GetPlayingAnimationTracks()) do
					if v.Name == "GroundPoundLand" or v.Name == "GroundPoundAnim" then
						v:Stop()
					end
				end
			end)
		end
		if char:FindFirstChild("GP") and HRP.Anchored == false then
			if raycastResult.Instance.Name == "Crate" then
				GPDust(raycastResult.Position.Y)
				local effect = game:GetService("ReplicatedStorage").Effects:FindFirstChild("Box_Break"):Clone()
				effect.CFrame = raycastResult.Instance.CFrame
				effect.Parent = workspace
				effect.Attachment.Planks:Emit(effect.Attachment.Planks:GetAttribute("EmitCount"))
				game.Debris:AddItem(effect, 1.5)
				raycastResult.Instance:Destroy()
			else
				GPDust(raycastResult.Position.Y)
				char:FindFirstChild("GP"):Destroy()
				local stars = game:GetService("ReplicatedStorage").Effects:WaitForChild("ColoredStars"):Clone()
				stars.CFrame = HRP.CFrame + Vector3.new(0,-3,0)
				stars.Parent = workspace
				print("adawdasdaqwdas!!!!")
				for i, v in pairs(stars:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(math.random(0,2))
					end
				end
			end
		end
	elseif hum.floorMaterial ~= Enum.Material.Air then
		if char:FindFirstChild("GP") then
			char:FindFirstChild("GP"):Destroy()
			GPDust(HRP.Position.Y - 2.8)
		end
	end
	
	
	
	
	
	if char:FindFirstChild("Slide") or char:FindFirstChild("DiveCooldown") then
		local raycastResult2 = workspace:Raycast(HRP.Position, Vector3.new(0,-1 - (math.abs(HRP.AssemblyLinearVelocity.Y)/10),0), params)
		--print(-0.12 * math.abs(HRP.AssemblyLinearVelocity.Y - 1))
		if raycastResult2 and raycastResult2.Instance and raycastResult2.Instance.CanCollide == true then
			if raycastResult2.Instance.Name == "Enemy" then return end
			if char:FindFirstChild("DiveCooldown") then
				char:FindFirstChild("DiveCooldown"):Destroy()
			end
			if char:FindFirstChild("Slide") and raycastResult2.Instance.Name ~= "Spring" and canSlide == true then
				if HRP.AssemblyLinearVelocity.Magnitude > 3 then
					char:FindFirstChild("Slide").Value = true
					--print("on Ground")
				else
					char:FindFirstChild("Slide"):Destroy()
				end
			end
		else
			if char:FindFirstChild("Slide") then
				char:FindFirstChild("Slide").Value = false
				--print("Not on Ground")
			end
		end
	end
	
	
	
	if char:FindFirstChild("LongJumpCD") then
		for i, v in pairs(workspace:GetDescendants()) do
			if v.Name == "Water" then
				LJparams:AddToFilter(v)
			end
		end
		local LongJumpRaycast = workspace:Raycast(HRP.Position, Vector3.new(0,-3,0), LJparams)
		if LongJumpRaycast and LongJumpRaycast.Instance then
			char:FindFirstChild("LongJumpCD"):Destroy()
			if HRP:FindFirstChild("LongJumpAO") then
				HRP:FindFirstChild("LongJumpAO"):Destroy()
			end
			hum:ChangeState("GettingUp")
			for i, v in pairs(animator:GetPlayingAnimationTracks()) do
				if v.Name == "LongJump" then
					warn("adawdasdawd")
				v:Stop()
				end
			end
			HRP.AssemblyLinearVelocity = Vector3.zero
			for i = 1, 5 do
				local dustpart = game:GetService("ReplicatedStorage").Effects.Meshes.IcoSphere:Clone()
				dustpart.CFrame = HRP.CFrame + Vector3.new(0,-3,0)
				dustpart.Parent = workspace
				local size = (math.random(100,200)/100)
				local tweenP = TS:Create(dustpart, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Vector3.new(dustpart.Position.X + (math.random(-400,400)/100), dustpart.Position.Y + (math.random(50,200)/100), dustpart.Position.Z + (math.random(-400,400)/100))})
				local tweenS = TS:Create(dustpart, TweenInfo.new(0.25), {Size = Vector3.new(size, size, size)})
				local tweenR = TS:Create(dustpart, TweenInfo.new(0.5), {Orientation = Vector3.new(math.random(0,180), math.random(0,180), math.random(0,180))})
				tweenP:Play()
				tweenS:Play()
				tweenR:Play()
				delay(0.25, function()
					local tweenS2 = TS:Create(dustpart, TweenInfo.new(0.25), {Size = Vector3.new(0, 0, 0)})
					tweenS2:Play()
				end)
				game.Debris:AddItem(dustpart, 0.5)
			end
		end
	end
	
	local SlopeRaycastResult = workspace:Raycast(HRP.Position, Vector3.new(0,-6,0), params)
	
	if SlopeRaycastResult and SlopeRaycastResult.Instance then
		if math.abs(SlopeRaycastResult.Normal.X) > 0.7 or math.abs(SlopeRaycastResult.Normal.Z) > 0.7 then
			if char:FindFirstChild("GP") then
				char:FindFirstChild("GP"):Destroy()
			end
			if char:FindFirstChild("GPLand") then
				char:FindFirstChild("GPLand"):Destroy()
			end
			if not char:FindFirstChild("SlopeFall") then
				print("FALLING")
				local slopeFall = Instance.new("BoolValue", char)
				slopeFall.Name = "SlopeFall"
			end
			hum.WalkSpeed = 0
			hum.JumpHeight = 0
			game:GetService("ReplicatedStorage"):WaitForChild("Dive"):Fire()
		else
			for i, v in char:GetChildren() do
				if v.Name == "SlopeFall" then
					v:Destroy()
					hum.WalkSpeed = 16
					hum.JumpHeight = 7.201
				end
			end
		end
	end
end
