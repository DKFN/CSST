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

    self:Super().Constructor(self, "TRACE", {
        vLocation,
        vLocation,
        radius,
        eCollisionChannel,
        tIgnoredActor,
        nTickEvery,
        bDebugDraw
    })
end
