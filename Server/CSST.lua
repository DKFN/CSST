--- Client Side Synced Triggers
---
--- Allows to create triggers on the server side that will be computed on the client side
CSST = CSST_Base.Inherit("CSST")

--- TODO: Now we must keep in track of the overlapped entities so we can
--- TODO: Discard duplicates begin overlaps on network authority switch
---

--- Mirrors the Trigger constructor for nanos world https://docs.nanos.world/docs/scripting-reference/classes/trigger
---@param vLocation Vector Location of the trigger
---@param rRotation Rotator Rotation of the trigger
---@param vfExtent Vector | Float 
---@param eTriggerType TriggerType
---@param bDebugDraw boolean
---@param eDebugColor Color
function CSST:Constructor(vLocation, rRotation, eTriggerType, vfExtent, bDebugDraw, eDebugColor, tOverlapOnlyClasses)
    self:Super().Constructor(self, {
        vLocation,
        rRotation,
        eTriggerType,
        vfExtent,
        bDebugDraw,
        eDebugColor,
        tOverlapOnlyClasses
    })

    -- Native calls

    -- Trigger class
    self.ForceOverlapChecking = CSST._registerNativeCall(self, "ForceOverlapChecking")
    self.SetColor = CSST._registerNativeCall(self, "SetColor")
    self.SetExtent = CSST._registerNativeCall(self, "SetExtent")
    self.SetOverlapOnlyClasses = CSST._registerNativeCall(self, "SetOverlapOnlyClasses")

    -- Actor class
    self.AddActorTag = CSST._registerNativeCall(self, "AddActorTag")
    self.AddImpulse = CSST._registerNativeCall(self, "AddImpulse")
    self.AttachTo = CSST._registerNativeCall(self, "AttachTo")
    self.Detach = CSST._registerNativeCall(self, "Detach")
    
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

    self.RemoveActorTag = CSST._registerNativeCall(self, "RemoveActorTag")
    self.RotateTo = CSST._registerNativeCall(self, "RotateTo")
    self.SetCollision = CSST._registerNativeCall(self, "SetCollision")
    self.SetDimension = CSST._registerNativeCall(self, "SetDimension")
    self.SetForce = CSST._registerNativeCall(self, "SetForce")
    self.SetGravityEnabled = CSST._registerNativeCall(self, "SetGravityEnabled")
    self.SetHighlightEnabled = CSST._registerNativeCall(self, "SetHighlightEnabled")
    self.SetLifeSpan = CSST._registerNativeCall(self, "SetLifeSpan")
    self.SetLocation = CSST._registerNativeCall(self, "SetLocation")
    self.SetNetworkAuthorityAutoDistributed = CSST._unregisteredNativeFunction(self, "IsVisible")
    self.SetOutlineEnabled = CSST._registerNativeCall(self, "SetOutlineEnabled")
    self.SetRelativeLocation = CSST._registerNativeCall(self, "SetRelativeLocation")
    self.SetRelativeRotation = CSST._registerNativeCall(self, "SetRelativeRotation")
    self.SetRotation = CSST._registerNativeCall(self, "SetRotation")
    self.SetScale = CSST._registerNativeCall(self, "SetScale")
    self.SetVisibility = CSST._registerNativeCall(self, "SetVisibility")
    self.TranslateTo = CSST._registerNativeCall(self, "TranslateTo")
    self.WasRecentlyRendered = CSST._unregisteredNativeFunction(self, "WasRecentlyRendered")
end


Events.SubscribeRemote("CSST:Event", function(player, nCsstTriggerID, sEventName, ...)
    local csstInstance = CSST.GetByID(nCsstTriggerID)
    if (csstInstance) then
        if (player:IsValid() and player == csstInstance.authority) then
            Console.Log("Found trigger Instance :"..NanosTable.Dump(csstInstance))
            csstInstance:_HandleEvent(sEventName, ...)
        end
    end
end)
