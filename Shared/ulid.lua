--[[
    ULID
    GNU General Public License v3.0
    Copyright © Timmy-the-nobody, 2024, https://github.com/Timmy-the-nobody
]]--

local rand = math.random
local concat = table.concat
local format = string.format
local sub = string.sub
local osTime = os.time

math.randomseed((os.time() * 1000) + rand(0, 999999))

ULID = ULID or {}
Package.Export("ULID", ULID)

local __tULIDMap = {}

-- Number of entropy characters (total length will be 10 + this value)
local iEntropyChars = 16
-- ULID regex pattern, used for validation
local sULIDPattern = "^"..string.rep("[0-9a-f]", 10 + iEntropyChars).."$"

-- Cache hex code, for faster lookup
local tHexMap = {}
for i = 0, 15 do tHexMap[i] = format("%x", i) end

-- Internal function that generates the ULID hash
local function generateULID()
    local tEntropy = {}
    for i = 1, iEntropyChars do
        tEntropy[#tEntropy + 1] = tHexMap[rand(0, 15)]
    end
    return sub(format("%010x", osTime() * 100), -10)..concat(tEntropy)
end

---`🔸 Client`<br>`🔹 Server`<br>
---Generate a random ULID
---@param xData? any @The data to bind to the ULID, defaults to `true`
---@return string @The generated ULID
---
function ULID.Generate(xData)
    local sULID = generateULID()
    if (__tULIDMap[sULID] ~= nil) then
        return ULID.Generate()
    end

    __tULIDMap[sULID] = (xData ~= nil) and xData or true
    return sULID
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the ULID registry
---@return table<string, any> @The ULID registry
---@see ULID.Get
---
function ULID.GetTable()
    return __tULIDMap
end

---`🔸 Client`<br>`🔹 Server`<br>
---Return a value binded to the passed ULID
---@param sULID string @The ULID to search
---@return any @The value binded to the ULID, defaults to `true`
---@see ULID.GetTable
---
function ULID.Get(sULID)
    return __tULIDMap[sULID]
end

---`🔸 Client`<br>`🔹 Server`<br>
---Adds an ULID to the cache
---@param sULID string @The ULID to add
---@param xData? any @The data to bind to the ULID, defaults to `true`
---@see ULID.Clear
---
function ULID.Store(sULID, xData)
    if (type(sULID) ~= "string") or not sULID:IsULID() then return end
    __tULIDMap[sULID] = (xData ~= nil) and xData or true
end

---`🔸 Client`<br>`🔹 Server`<br>
---Removes the ULID from the cache
---@param sULID string @The ULID to remove<br>
---@see ULID.Store
---
function ULID.Clear(sULID)
    if (type(sULID) ~= "string") then return end
    __tULIDMap[sULID] = nil
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns wether the string is an ULID
---@param self string @The string to check
---@return boolean @Wether the string is an ULID
---
function string.IsULID(self)
    if not self or (#self ~= (10 + iEntropyChars)) then return false end
    return string.match(self, sULIDPattern) ~= nil
end