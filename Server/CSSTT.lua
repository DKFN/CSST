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

