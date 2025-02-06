local handledTriggers = {}


local function registerDelegatedEvent(csstTrigger, sEventName, nCsstTriggerID)
    csstTrigger:Subscribe(sEventName, function(_self, ...)
        Console.Log("Trigger event !")
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
    Console.Log("Received start trigger params"..NanosTable.Dump(tTriggerParams))
    Console.Log("Received start trigger callst"..NanosTable.Dump(tNativeCallStack))
    handledTriggers[nCsstTriggerID] = Trigger(table.unpack(tTriggerParams))

    -- Console.Log("Handled triggers "..NanosTable.Dump(handledTriggers))
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

Package.Require("./CSSTT.lua")
CSSTT_Sphere(
    Vector(-16833.05, 14274, 198),
    Vector(-16833.05, 14274, 198),
    200,
    CollisionChannel.Pawn,
    {},
    1
)
