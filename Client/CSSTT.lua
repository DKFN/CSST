CSSTT_Sphere = BaseClass.Inherit("CSSTT_Sphere")

local MAX_TICK_SKIP = 1000

--- CSSTT are Traces that behaves like triggers
---
function CSSTT_Sphere:Constructor(
    nServerId,
    start_location,
    end_location,
    radius,
    collision_channel,
    ingored_actors,
    check_every
)
    self.serverId = nServerId
    self.startLocation = start_location
    self.endLocation = end_location
    self.radius = radius
    self.collisionChannel = collision_channel or CollisionChannel.WorldStatic
    self.ignoredActors = ingored_actors or {}
    self.checkEvery = check_every or 1
    self.traceMode = TraceMode.ReturnEntity

    -- Natives handling
    self.attachedEntity = nil

    Console.Log("check every value "..NanosTable.Dump(self.checkEvery))

    self.tickSpreadValue = self:GetID() % self.checkEvery

    self.overlappingEntitiesSeq = {}
    self.tOverlappingEntitiesHash = {}

    -- Debug params
    self.assignedDebugDrawFrame = self:GetID() % 100 -- Mitigate stutter mayhem when debugging
end

local Trace_SphereMulti = Trace.SphereMulti
local _ipairs = ipairs
function CSSTT_Sphere:Main(tickCount)
    local vTargetLocation = self.startLocation
    if (self.attachedEntity) then
        vTargetLocation = self.attachedEntity:GetLocation()
    end

    local traceResult = Trace_SphereMulti(
        vTargetLocation,
        vTargetLocation,
        self.radius,
        self.collisionChannel,
        self.traceMode,
        self.ignored_actors
    )

    -- Updates the overlapping entity
    local tNextOverlappingEntitiesSeq = {}
    local tNextOverlappingEntitiesHash = {}

    -- Check for new entities inside trigger
    for k, v in _ipairs(traceResult) do
        local entity = v.Entity
        if (entity) then
            tNextOverlappingEntitiesSeq[#tNextOverlappingEntitiesSeq+1] = entity
            tNextOverlappingEntitiesHash[entity] = entity
            if (not self.tOverlappingEntitiesHash[entity]) then
                Events.CallRemote("CSST:Event:1", self.serverId, "BeginOverlap", entity)
            end
        end
    end

    -- Check for entities that left the trigger
    for k, v in _ipairs(self.overlappingEntitiesSeq) do
        if (not tNextOverlappingEntitiesHash[v]) then
            if (v and v:IsValid() and not v:IsBeingDestroyed()) then
                Events.CallRemote("CSST:Event:1", self.serverId, "EndOverlap", v)
            end
        end
    end
    self.overlappingEntitiesSeq = tNextOverlappingEntitiesSeq
    self.tOverlappingEntitiesHash = tNextOverlappingEntitiesHash
end

function CSSTT_Sphere:AttachTo(entity)
    self.attachedEntity = entity
end

local _getall = CSSTT_Sphere.GetAll
local _main = CSSTT_Sphere.Main
local tickCount = 0
Client.Subscribe("Tick", function()
    for k, sphereTrigger in _ipairs(_getall()) do
        if (tickCount % (sphereTrigger.checkEvery + sphereTrigger.tickSpreadValue) == 0) then
            sphereTrigger:Main(tickCount)
        end
    end
    tickCount = tickCount + 1
    if (tickCount > MAX_TICK_SKIP) then
        tickCount = 0
    end
end)

local e = {
    a = 1,
    b = 2
}

Console.Log(e.a + e.b)
