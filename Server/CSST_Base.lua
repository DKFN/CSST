
CSST_Base = BaseClass.Inherit("CSST_Base")

function CSST_Base:Constructor(triggerParams)
    self.subscribedEvents = {}
    self.triggerParams = triggerParams
    self.authority = nil
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
    self:_Log("Starting clientside handling")
    Events.CallRemote("CSST:START_TRIGGER",
        self.authority,
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
