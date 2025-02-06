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

    --- {name = sFunctionName, params = {}}
    self.nativeCallStack = {} -- History of native function called to be replayed on the client on authority switch

    --- Indexed by entityId and if it is overlapping
    self.tOverlappingEntities = {

    }

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

function CSST:GetNetworkAuthority()
    return self.authority
end

local table_pack = table.pack
function CSST:_HandleEvent(sEventName, varg1, ...)
    local discardEvent = false
    local aFirstEventParam = varg1

    --if (aFirstEventParam and aFirstEventParam.IsValid and not aFirstEventParam:IsValid()) then
     --   discardEvent = true
    --end

    local fDestructionHandler = function(entity)
        self:_HandleEvent("EndOverlap", entity)
    end
    
    if (sEventName == "BeginOverlap" and aFirstEventParam) then
        local bOverlappingStatusEntity = self.tOverlappingEntities[aFirstEventParam]
        if (bOverlappingStatusEntity) then
            discardEvent = true
        else
            self.tOverlappingEntities[aFirstEventParam] = true
            aFirstEventParam:Subscribe("Destroy", fDestructionHandler)
        end
    end

    if (sEventName == "EndOverlap" and aFirstEventParam) then
        local bOverlappingStatusEntity = self.tOverlappingEntities[aFirstEventParam]
        if (bOverlappingStatusEntity) then
            self.tOverlappingEntities[aFirstEventParam] = false
            aFirstEventParam:Unsubscribe("Destroy", fDestructionHandler)
        end
    end

    if (discardEvent) then
        return
    end

    
    -- self:_Log("Handing event "..sEventName.. "for "..NanosTable.Dump(aFirstEventParam))
    local fCallback = self.subscribedEvents[sEventName]
    if (fCallback) then
        Console.Log("Call back called"..NanosTable.Dump(aFirstEventParam))
        fCallback(self, aFirstEventParam, ...)
    end
end

function CSST:HandleEntityDestroyed()
    return function (entity)
        if (self.tOverlappingEntities[entity]) then
            self:Super():_Log("Destroying entity, scanning CSST. Was overlapping : "..NanosTable.Dump(entity))
            self:_HandleEvent("EndOverlap", entity)
        end
    end
end

function CSST:Destrutor()
    self:Super().Destructor(self)
end

Events.SubscribeRemote("CSST:Event", function(player, nCsstTriggerID, sEventName, ...)
    local csstInstance = CSST.GetByID(nCsstTriggerID)
    if (csstInstance) then
        if (player:IsValid() and player == csstInstance.authority) then
            Console.Log("Found trigger event :")
            csstInstance:_HandleEvent(sEventName, ...)
        end
    end
end)
