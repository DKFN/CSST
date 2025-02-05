local handledTriggers = {}


local function registerDelegatedEvent(csstTrigger, sEventName, nCsstTriggerID)
    csstTrigger:Subscribe(sEventName, function(_self, ...)
        Events.CallRemote("CSST:Event", nCsstTriggerID, sEventName, ...)
    end)
end

local function handleNativeCall(nCsstTriggerID, sNativeFunction, ...)
    local maybeHandledTrigger = handledTriggers[nCsstTriggerID]
    if (maybeHandledTrigger) then
        maybeHandledTrigger[sNativeFunction](maybeHandledTrigger, ...)
    end
end

Events.SubscribeRemote("CSST:START_TRIGGER", function(nCsstTriggerID, tTriggerParams, tNativeCallStack)
    Console.Log("Received start trigger")
    handledTriggers[nCsstTriggerID] = Trigger(table.unpack(tTriggerParams))

    Console.Log("Handled triggers "..NanosTable.Dump(handledTriggers))
    local csstTrigger = handledTriggers[nCsstTriggerID]
    registerDelegatedEvent(csstTrigger, "BeginOverlap", nCsstTriggerID)
    registerDelegatedEvent(csstTrigger, "EndOverlap", nCsstTriggerID)
    for k, nativeCall in ipairs(tNativeCallStack) do
        handleNativeCall(nCsstTriggerID, nativeCall.name, table.unpack(nativeCall.params))
    end
end)

Events.SubscribeRemote("CSST:NATIVE_CALL", handleNativeCall)
Events.SubscribeRemote("CSST:STOP_TRIGGER", function(nCsstTriggerID)
    local maybeHandledTrigger = handledTriggers[nCsstTriggerID]
    if (maybeHandledTrigger) then
        maybeHandledTrigger:Destroy()
    end
end)

-- TODO: Move that to CSST_SphereTrace
local tickCounter = 1
Client.Subscribe("Tick", function()
    for k, trigger in pairs(handledTriggers) do

        for k, char in pairs(Character.GetAll()) do
            Console.Log("Calcul de distance")
            char:GetLocation():Distance(Vector(0,0,0))
        end
        -- Console.Log("Launching trace creation")
        -- Trace.SphereMulti(
        --    Vector(-16020.46, 16523.13, 198),
        --    Vector(-16020.46, 16523.13, 198),
        --    -- Vector(-17011.80, 16471, 198),
        --    3000.0,
        --    CollisionChannel.Pawn,
        --    -- TraceMode.DrawDebug | TraceMode.ReturnEntity
        --    TraceMode.ReturnEntity
        -- )
    end
    tickCounter = tickCounter + 1
    if (tickCounter > 10000) then
        tickCounter = 1
    end
end
)
