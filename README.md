# Client Side Synced Triggers

CSST is a package that aims to allow you to use Triggers in the Server without the computational cost of a serverside Trigger.

This of course comes with tradeoffs, but it hopefully offers a drop-in replacement for use cases that can tolerate network delays and will leave more room on the server for Triggers that require speed and precision.

CSST comes also with CSSTT, an alternative implementation of Triggers that can help you acheive great performance gains with additionnal tradeoffs (nothing is free! :D).

CSST was developped for the needs of [NACT](https://github.com/DKFN/NACT) but aims to cover your needs too. Feel free to contribute to the project !

However, be aware that for the time being my main focus is NACT alpha version. As such, some stuff are partially implemented only to answer the needs of NACT (especially in CSSTTs)

```
I STRONGLY recommend to NOT use this lib before having higher performance needs for Triggers.

Remember, CSST will never be as easy, stable and complete as the NanosWorld triggers.

Save yourself the headaches for when they are needed, not early in your project ! :)
```


# API
## CSST

CSST is the class that handles clienside triggers copying the NanosWorld implementation on the server, and offloading calculations to the network authority. If no network authority is defined, nothing will happend until an authority is set.

Instead of writing:
```lua
local my_trigger = Trigger(Vector(-200, 100, 500), Rotator(), Vector(100), TriggerType.Sphere, true, Color(1, 0, 0))
my_trigger:SetLocation(Vector())
```
Write:
```lua
local my_trigger = CSST(Vector(-200, 100, 500), Rotator(), Vector(100), TriggerType.Sphere, true, Color(1, 0, 0))
my_trigger:SetLocation(Vector())
```

For the rest, they behave exactly like a normal serverside trigger.
```lua
my_trigger:Subscribe("BeginOverlap", function(entity)
    Console.Log("Ohoh something entered the trigger !")
end)


my_trigger:Subscribe("EndOverlap", function(entity)
    Console.Log("Nooooo, come back ! :(")
end)
```


Due to the fact that the triggers are spawned on the client consider the following tradeoffs:
- `Networking lag` since it relies on the network, events and functions calls will be subjected to the network delay for synchronizing the state between the client and the server
- `Write only` most of the `Get` or `Is` functions are unavailable, since the entity does not really exist on the server, and querying would be async. (`GetLocation` or `IsVisible` for example) 

However, there is a good chance most of your triggers will be ok with thoose limitations.
For the orthers, it is best to use normal Trigers on the server.

We would like to support NetworkAuthorithy copying from an entity, but we cannot reliably do so for now. So you must explicitly call `my_trigger:SetNetworkAuthority(elected_player)` !

## CSSTT
CSSTT is anorther implementation of Triggers that relies on Traces instead of Triggers.

The most powerful feature of CSSTT compared to CSST or Triggers is that you can skip ticks for overlap checkings, this is ideal if you do not need a super-precise Trigger and can help save a lot of calculations of the client side.
Aditionally, overlap checks are spread between ticks. If you have 10 triggers that checks every 10 ticks, they will be spread in their own tick instead of performing the 10 checks in the same tick.

CSSTTs overlap checks are twice slower than clientside triggers. However, the ability to skip ticks
make a very interesting alternative.

However, be aware that CSSTT are not Actors on the client side ! Thus, only a few functions are available. But again, if your use case meets the tradeoffs, CSSTTs are a powerful alternative in trigger heavy code.

CSSTT can be spawned on the server like so:
```lua
local my_trigger = CSSTT(TriggerType.Sphere, Vector(-200, 100, 500), 200, CollisionChannel.Pawn, {}, 50)
```

The constructor is different than native triggers, it takes the following parameters:
| Name | Type | Description |
|------|------|-------------|
| eTriggerType | [TriggerType](https://docs.nanos.world/docs/scripting-reference/glossary/enums#triggertype)    | Only TriggerType.Sphere is supported at the moment         |
| vLocation | [Vector](https://docs.nanos.world/docs/scripting-reference/structs/vector)   | Center location of the Trigger |
| radius | Number | Radius of the sphere |
| eCollisionChannel | [CollisionChannel](https://docs.nanos.world/docs/scripting-reference/glossary/enums#collisionchannel)  | The collision channels of the Trigger. Beware, this is not the same as a trigger! |
| tIgnoredActor | Table | (Optional) Table of actors to ignore while tracing. Default to `{}` |
| nTickEvery | Number | (Optional) Every ticks to perform overlap checks. 1 will overlap check each ticks, 10 will overlap check every 10 ticks. |
| bDebugDraw | Boolean | (Optional)(Unused) Left there just in case, was used at one point but not great. needs better impl |

There is only three native methods supported for now
```lua
my_trigger:AttachTo(entity)
my_trigger:Subscribe("BeginOverlap", function(entity)
    Console.Log("Ohoh something entered the trigger !")
)
my_trigger:Subscribe("EndOverlap", function(entity)
    Console.Log("Nooooo, come back ! :(")
end)
```

I hope you find this lib useful.
And don't get greedy, use it when you need it and not just because !
