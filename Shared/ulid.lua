--[[
    ULID
    GNU General Public License v3.0
    Copyright © Timmy-the-nobody, 2024, https://github.com/Timmy-the-nobody
]]--

local rand = math.random
local concat = table.concat
local osTime = os.time

ULID = ULID or {}
Package.Export("ULID", ULID)

math.randomseed((osTime() * 1000) + rand(0, 999999))

local __tULIDMap = {}
local iEntropyChars = 16

-- ULID pattern (used for fast validation in `string.IsULID`)
local sULIDPattern = "^"..string.rep("[0-9A-HJ-NP-TV-Z]", 10 + iEntropyChars).."$"

-- Base32 character lookup table
local sBase32Chars = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
local tBase32Map = {}
for i = 0, 31 do
    tBase32Map[i] = sBase32Chars:sub(i + 1, i + 1)
end

-- Convert a number to Base32 efficiently
local function toBase32(iNum, iLen)
    local tRes = {}
    for i = iLen, 1, -1 do
        tRes[i] = tBase32Map[iNum % 32]
        iNum = math.floor(iNum / 32)
    end
    return concat(tRes)
end

-- Generate an ULID
local function generateULID()
    local tEntropy = {}
    for i = 1, iEntropyChars do
        tEntropy[i] = tBase32Map[math.random(0, 31)]
    end

    return toBase32(math.floor(osTime() * 1000), 10)..concat(tEntropy)
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
    return (type(self) == "string") and (string.match(self, sULIDPattern) ~= nil)
end