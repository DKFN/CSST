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

local Trace_SphereMulti = Trace.SphereMulti
local _ipairs = ipairs
function CSSTT_Sphere:Main(tickCount)
    local traceDrawMode
    if (tickCount % 290 == 0) then
        traceDrawMode = self.traceMode | TraceMode.DrawDebug
    else
        traceDrawMode = self.traceMode
    end

    local traceResult = Trace_SphereMulti(
        self.startLocation,
        self.endLocation,
        self.radius,
        self.collisionChannel,
        traceDrawMode,
        self.ignored_actors
    )

    -- Updates the overlapping entity
    local tNextOverlappingEntitiesSeq = {}
    local tNextOverlappingEntitiesHash = {}
    for k, v in _ipairs(traceResult) do
        local entity = v.Entity
        if (entity) then
            tNextOverlappingEntitiesSeq[#tNextOverlappingEntitiesSeq+1] = entity
            tNextOverlappingEntitiesHash[entity] = entity
            if (not self.tOverlappingEntitiesHash[entity]) then
                Chat.AddMessage("Entity started overlapping")
            end
        end
    end

    for k, v in _ipairs(self.overlappingEntitiesSeq) do
        if (not tNextOverlappingEntitiesHash[v]) then
            Chat.AddMessage("Entity overlapping has stopped")
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
    if (tickCount > 10000) then
        tickCount = 10000
    end
end)
