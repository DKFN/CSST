CSSTT_Sphere = BaseClass.Inherit("CSSTT_Sphere")

--- CSSTT are Traces that behaves like triggers
---
function CSSTT_Sphere:Constructor(
    start_location,
    end_location,
    radius,
    collision_channel,
    ingored_actors,
    check_every
)
    self.startLocation = start_location
    self.endLocation = end_location
    self.radius = radius
    self.collisionChannel = collision_channel or CollisionChannel.WorldStatic
    self.ignoredActors = ingored_actors or {}
    self.checkEvery = check_every or 1
    self.traceMode = TraceMode.ReturnEntity

    self.overlappingEntitiesSeq = {}
end

function CSSTT_Sphere:Main(tickCount)
    local traceDrawMode
    if (tickCount % 400) then 
        traceDrawMode = self.collisionChannel | TraceMode.DrawDebug
    else
        traceDrawMode = self.collisionChannel
    end

    local traceResult = Trace.SphereMulti(
        self.startLocation,
        self.endLocation,
        self.radius,
        traceDrawMode,
        self.traceMode,
        self.ignored_actors
    )

    -- Updates the overlapping entity
    local tNextOverlappingEntitiesSeq = {}
    local tNextOverlappingEntitiesHash = {}
    for k, v in ipairs(traceResult) do
        local entity = v.Entity
        if (entity) then
            tNextOverlappingEntitiesSeq[#tNextOverlappingEntitiesSeq+1] = entity
            tNextOverlappingEntitiesHash[entity] = entity
            if (not self.tOverlappingEntitiesHash[entity]) then
                Console.Log("Entity started overlapping")
            end
        end
    end

    for k, v in pairs(self.overlappingEntitiesSeq) do
        if (not tNextOverlappingEntitiesHash[v]) then
            Console.Log("Entity overlapping has stopped")
        end
    end
    self.overlappingEntitiesSeq = tNextOverlappingEntitiesSeq
    self.tOverlappingEntitiesHash = tNextOverlappingEntitiesHash
end

local _getall = CSSTT_Sphere.GetAll
local tickCount = 0
Client.Subscribe("Tick", function()
    for k, sphereTrigger in ipairs(_getall()) do
        if (tickCount % sphereTrigger.checkEvery == 0) then
            sphereTrigger:Main(tickCount)
        end
    end
    tickCount = tickCount + 1
end)
