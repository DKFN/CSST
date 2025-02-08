CSSTT = CSST_Base.Inherit("CSSTT")

function CSSTT:Constructor(
    eTriggerType,
    vLocation,
    radius,
    eCollisionChannel,
    tIgnoredActor,
    nTickEvery,
    bDebugDraw
)
    if (eTriggerType ~= TriggerType.Sphere) then
        Console.Error("CSSTT only support spheres for now. Use a CSST or a Trigger instead, sorry !")
        return
    end

    self:Super().Constructor(self, 1, {
        vLocation,
        vLocation,
        radius,
        eCollisionChannel,
        tIgnoredActor,
        nTickEvery,
        bDebugDraw
    })

    self.AttachTo = CSST._registerNativeCall(self, "AttachTo")

    self.ForceOverlapChecking = CSST._unregisteredNativeFunction(self, "ForceOverlapChecking")
    self.SetColor = CSST._unregisteredNativeFunction(self, "SetColor")
    self.SetExtent = CSST._unregisteredNativeFunction(self, "SetExtent")
    self.SetOverlapOnlyClasses = CSST._unregisteredNativeFunction(self, "SetOverlapOnlyClasses")

    -- Actor class
    self.AddActorTag = CSST._unregisteredNativeFunction(self, "AddActorTag")
    self.AddImpulse = CSST._unregisteredNativeFunction(self, "AddImpulse")
    self.Detach = CSST._unregisteredNativeFunction(self, "Detach")
    
    self.GetAttachedEntities = CSST._unregisteredNativeFunction(self, "GetAttachedEntities")
    self.GetAttachedTo = CSST._unregisteredNativeFunction(self, "GetAttachedTo")
    self.GetBounds = CSST._unregisteredNativeFunction(self, "GetBounds")
    self.GetCollision = CSST._unregisteredNativeFunction(self, "GetCollision")
    self.GetDimension = CSST._unregisteredNativeFunction(self, "GetDimension")
    self.GetDistanceFromCamera = CSST._unregisteredNativeFunction(self, "GetDistanceFromCamera")
    self.GetForce = CSST._unregisteredNativeFunction(self, "GetForce")
    self.GetLocation = CSST._unregisteredNativeFunction(self, "GetLocation")
    self.GetRelativeLocation = CSST._unregisteredNativeFunction(self, "GetRelativeLocation")
    self.GetRelativeRotation = CSST._unregisteredNativeFunction(self, "GetRelativeRotation")
    self.GetRotation = CSST._unregisteredNativeFunction(self, "GetRotation")
    self.GetScale = CSST._unregisteredNativeFunction(self, "GetScale")
    self.GetScreenPercentage = CSST._unregisteredNativeFunction(self, "GetScreenPercentage")
    self.GetVelocity = CSST._unregisteredNativeFunction(self, "GetVelocity")
    
    self.IsGravityEnabled = CSST._unregisteredNativeFunction(self, "IsGravityEnabled")
    self.IsInWater = CSST._unregisteredNativeFunction(self, "IsInWater")
    self.IsNetworkDistributed = CSST._unregisteredNativeFunction(self, "IsNetworkDistributed")
    self.IsVisible = CSST._unregisteredNativeFunction(self, "IsVisible")

    self.RemoveActorTag = CSST._unregisteredNativeFunction(self, "RemoveActorTag")
    self.RotateTo = CSST._unregisteredNativeFunction(self, "RotateTo")
    self.SetCollision = CSST._unregisteredNativeFunction(self, "SetCollision")
    self.SetDimension = CSST._unregisteredNativeFunction(self, "SetDimension")
    self.SetForce = CSST._unregisteredNativeFunction(self, "SetForce")
    self.SetGravityEnabled = CSST._unregisteredNativeFunction(self, "SetGravityEnabled")
    self.SetHighlightEnabled = CSST._unregisteredNativeFunction(self, "SetHighlightEnabled")
    self.SetLifeSpan = CSST._unregisteredNativeFunction(self, "SetLifeSpan")
    self.SetLocation = CSST._unregisteredNativeFunction(self, "SetLocation")
    self.SetNetworkAuthorityAutoDistributed = CSST._unregisteredNativeFunction(self, "IsVisible")
    self.SetOutlineEnabled = CSST._unregisteredNativeFunction(self, "SetOutlineEnabled")
    self.SetRelativeLocation = CSST._unregisteredNativeFunction(self, "SetRelativeLocation")
    self.SetRelativeRotation = CSST._unregisteredNativeFunction(self, "SetRelativeRotation")
    self.SetRotation = CSST._unregisteredNativeFunction(self, "SetRotation")
    self.SetScale = CSST._unregisteredNativeFunction(self, "SetScale")
    self.SetVisibility = CSST._unregisteredNativeFunction(self, "SetVisibility")
    self.TranslateTo = CSST._unregisteredNativeFunction(self, "TranslateTo")
    self.WasRecentlyRendered = CSST._unregisteredNativeFunction(self, "WasRecentlyRendered")
end

function CSSTT:Destructor()
    self:Super().Destructor(self)
end

-- Causes "Failed to get environment from Lua stack! Did you call a function as tail call"
-- local _GetById = CSSTT.GetByID
Events.SubscribeRemote("CSST:Event:1", function(player, nCsstTriggerID, sEventName, ...)
    local csstInstance = CSSTT.GetByID(nCsstTriggerID)
    if (csstInstance) then
        if (player:IsValid() and player == csstInstance.authority) then
            -- Console.Log("Found trigger Instance :"..NanosTable.Dump(csstInstance))
            csstInstance:_HandleEvent(sEventName, ...)
        end
    end
end)

