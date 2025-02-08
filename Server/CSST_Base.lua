
CSST_Base = BaseClass.Inherit("CSST_Base")

function CSST_Base:Constructor(nTriggerType, triggerParams)
    self.subscribedEvents = {}
    self.triggerType = nTriggerType
    self.triggerParams = triggerParams
    self.authority = nil

    --- {name = sFunctionName, params = {}}
    self.nativeCallStack = {} -- History of native function called to be replayed on the client on authority switch

    --- Indexed by entityId and if it is overlapping
    self.tOverlappingEntities = {

    }

end

function CSST_Base:Destroy()
    self:_StopClientSideTriggerHandling()
end

function CSST_Base:Subscribe(sEventName, fCallback)
    self.subscribedEvents[sEventName] = fCallback
end

function CSST_Base:Unsubscribe(sEventName)
    self.subscribedEvents[sEventName] = nil
end

function CSST_Base:_NativeCall(sNativeFunction, ...)
    self.nativeCallStack[#self.nativeCallStack+1] = {
        name = sNativeFunction,
        params = table.pack(...)
    }

    if (self.authority) then
        Events.CallRemote("CSST:NATIVE_CALL", self.authority, self:GetID(), sNativeFunction, ...)
    end
end

function CSST_Base._registerNativeCall(self, sNativeFunction)
    return function(_s, ...)
        self._NativeCall(self, sNativeFunction, ...)
    end
end

function CSST_Base._unregisteredNativeFunction(self, sNativeFunction)
    return function(_s, ...)
        self:_Warn("Attempt to call native "..sNativeFunction.." but this native is not supported by CSST on the server. If you need this function, use proper server triggers")
    end
end

function CSST_Base:_Log(message)
    Console.Log("CSST #"..self:GetID().." : "..message)
end

function CSST_Base:_Warn(message)
    Console.Warn("CSST #"..self:GetID().." : "..message)
end


function CSST_Base:_StartClientSideTriggerHandling()
    -- self:_Log("Starting clientside handling")
    Events.CallRemote("CSST:START_TRIGGER",
        self.authority,
        self.triggerType,
        self:GetID(),
        self.triggerParams,
        self.nativeCallStack
    )
end

function CSST_Base:_StopClientSideTriggerHandling()
    if (self.authority:IsValid()) then
        -- self:_Log("Stopping clientside handling")
        Events.CallRemote("CSST:STOP_TRIGGER", self.authority, self:GetID())
    end
end

function CSST_Base:_ClearOverlapsOnNoAuthorithy()
    local fEndOverlapCallback = self.subscribedEvents["EndOverlap"]
    if (not fEndOverlapCallback) then
        return
    end

    for k, v in pairs(self.tOverlappingEntities) do
        if (self.tOverlappingEntities[k]) then
            self:_HandleEvent("EndOverlap", k)
        end
        --fEndOverlapCallback(self, k)
        -- self.tOverlappingEntities[k] = false
    end
end

function CSST_Base:SetNetworkAuthority(authority)
    if (authority == self.authority) then
        return
    end
    -- Console.Log("Switching network authority")
    if (self.authority) then
        self:_StopClientSideTriggerHandling()
    end
    
    -- Console.Log("Stop ok")
    self.authority = authority
    -- Console.Log("Assignation ok"..NanosTable.Dump(authority))
    if (self.authority) then
        -- Console.Log("Starting traces")
        self:_StartClientSideTriggerHandling()
    end

    if (not self.authority) then
        self:_ClearOverlapsOnNoAuthorithy()
    end
end

function CSST_Base:GetNetworkAuthority()
    return self.authority
end

local table_pack = table.pack
function CSST_Base:_HandleEvent(sEventName, varg1, ...)
    local discardEvent = false
    local aFirstEventParam = varg1

    if (not aFirstEventParam or (aFirstEventParam.IsValid and not aFirstEventParam:IsValid())) then
       discardEvent = true
    end

    local fDestructionHandler = function(entity)
        -- Console.Log("Destroying entity"..NanosTable.Dump(entity))
        -- self:_Log("Destroying entity, scanning CSST. Was overlapping : "..NanosTable.Dump(entity))
        self:_HandleEvent("EndOverlap", entity)
    end
    
    if (sEventName == "BeginOverlap") then
        -- Console.Log("Begin overlap for entity "..NanosTable.Dump(aFirstEventParam))
        local bOverlappingStatusEntity = self.tOverlappingEntities[aFirstEventParam]
        if (bOverlappingStatusEntity) then
            discardEvent = true
        else
            self.tOverlappingEntities[aFirstEventParam] = true
            aFirstEventParam:Subscribe("Destroy", fDestructionHandler)
        end
    end

    if (sEventName == "EndOverlap") then
        local bOverlappingStatusEntity = self.tOverlappingEntities[aFirstEventParam]
        -- Console.Log("End overlap for entity "..NanosTable.Dump(aFirstEventParam))
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
        -- Console.Log("Call back called "..sEventName.. "For : ".. NanosTable.Dump(aFirstEventParam))
        fCallback(self, aFirstEventParam, ...)
    end
end

function CSST_Base:HandleEntityDestroyed()
    return function (entity)
        if (self.tOverlappingEntities[entity]) then
            self:_HandleEvent("EndOverlap", entity)
        end
    end
end
