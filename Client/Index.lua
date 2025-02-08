local handledTriggers = {}

Package.Require("./CSSTT.lua")

local function registerDelegatedEvent(csstTrigger, sEventName, nCsstTriggerID)
    csstTrigger:Subscribe(sEventName, function(_self, ...)
        Console.Log("Trigger event !")
        Events.CallRemote("CSST:Event:0", nCsstTriggerID, sEventName, ...)
    end)
end

local function handleNativeCall(nCsstTriggerID, sNativeFunction, ...)
    local maybeHandledTrigger = handledTriggers[nCsstTriggerID]
    if (maybeHandledTrigger) then
        maybeHandledTrigger[sNativeFunction](maybeHandledTrigger, ...)
    end
end

Events.SubscribeRemote("CSST:START_TRIGGER", function(nTriggerType, nCsstTriggerID, tTriggerParams, tNativeCallStack)
    --Console.Log("Received start trigger params"..NanosTable.Dump(tTriggerParams))
    --Console.Log("Received start trigger callst"..NanosTable.Dump(tNativeCallStack))
    local cTriggerImplementation

    if (nTriggerType == 0) then
        cTriggerImplementation = Trigger
    else
        cTriggerImplementation = function (...)
            return CSSTT_Sphere(nCsstTriggerID, ...)
        end
    end

    handledTriggers[nCsstTriggerID] = cTriggerImplementation(table.unpack(tTriggerParams))

    -- Console.Log("Handled triggers "..NanosTable.Dump(handledTriggers))
    local csstTrigger = handledTriggers[nCsstTriggerID]

    if (nTriggerType == 0) then
        registerDelegatedEvent(csstTrigger, "BeginOverlap", nCsstTriggerID)
        registerDelegatedEvent(csstTrigger, "EndOverlap", nCsstTriggerID)
    end
    
    for k, nativeCall in ipairs(tNativeCallStack) do
        handleNativeCall(nCsstTriggerID, nativeCall.name, table.unpack(nativeCall.params))
    end
end)

Events.SubscribeRemote("CSST:NATIVE_CALL", handleNativeCall)
Events.SubscribeRemote("CSST:STOP_TRIGGER", function(nCsstTriggerID)
    local maybeHandledTrigger = handledTriggers[nCsstTriggerID]
    if (maybeHandledTrigger) then
        Console.Log("Destroying trigger")
        maybeHandledTrigger:Destroy()
    end
end)

-- CSSTT_Sphere(
--    0,
--    Vector(-16833.05, 14274, 198),
--    Vector(-16833.05, 14274, 198),
--    200,
--    CollisionChannel.Pawn,
--    {},
--    1
-- )
