
checklist = {}

computer = require "computer"
robot    = require "robot"

local states = {
 [1] = "All systems nominal",
 [2] = "Power low",
 [3] = "No usable tool",
 [4] = "Inventory low"
}

--each of these functions return true if the given situation needs remedying
local issueCheck = {
 [1] = function() return false end, -- all's good if all's good
 [2] = function(standard)
         return computer.energy() / computer.maxEnergy() < standard.power
       end,
 [3] = function()
         return robot.durability() == nil
       end,
 [4] = function(standard)
        freeSlots = 0
        for slotIndex=1,robot.inventorySize() do
          if robot.count(slotIndex) == 0 then
            freeSlots = freeSlots + 1
          end
        end
        return freeSlots < standard.inventory
      end
}

-- returns
local function metaChecker(powerThresh, invThresh)
  local weGood = true
  for i,v in ipairs(states) do
    if(issueCheck[i]({power= powerThresh, inventory=invThresh})) then
      return false, i, v
    end
  end
  return true, 1, states[1]
end

--while mining we need at least 10% power and 1 free inventory slot
function checklist.miningCheck()
  return metaChecker(.10, 1)
end

function checklist.restockCheck()
  return metaChecker(.9, robot.inventorySize())
end

return checklist
