--[[
    ULID
    GNU General Public License v3.0
    Copyright © Timmy-the-nobody, 2024, https://github.com/Timmy-the-nobody
]]--

local rand = math.random
local concat = table.concat
local type = type
local match = string.match
local byte = string.byte
local getMs = (Server and Server.GetTime or Client.GetTime)

math.randomseed((os.time() * 1000) + rand(0, 999999))

---@class ULID
ULID = ULID or {}
Package.Export("ULID", ULID)

local __tULIDMap = {}
local iEntropyChars = 16

-- This is not a config value: don't change it!
local iTotalChars = 10 + iEntropyChars

-- ULID pattern (used for fast validation in `string.IsULID`)
local sULIDPattern = "^"..string.rep("[0-9A-HJ-NP-TV-Z]", iTotalChars).."$"

-- Base32 encode/decode lookup tables
local tBase32Map = {}
local tBase32Decode = {}
do
    local sub = string.sub
    local sBase32Chars = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
    for i = 0, 31 do
        local sChar = sub(sBase32Chars, i + 1, i + 1)
        tBase32Map[i] = sChar
        tBase32Decode[byte(sChar)] = i
    end
end

-- Pre-allocated result buffer and monotonicity state
local tResult = {}
for i = 1, iTotalChars do tResult[i] = false end

local iLastMs = 0
local tLastEntropy = {}
for i = 1, iEntropyChars do tLastEntropy[i] = 0 end

-- Increment entropy as a big-endian base32 integer (for monotonic ordering within the same ms)
local function incrementEntropy()
    for i = iEntropyChars, 1, -1 do
        if (tLastEntropy[i] < 31) then
            tLastEntropy[i] = tLastEntropy[i] + 1
            return
        end
        tLastEntropy[i] = 0
    end
end

-- Generate a ULID (single-pass, bitwise ops, monotonic)
local function generateULID()
    local iTs = getMs()
    if (iTs <= iLastMs) then
        iTs = iLastMs
        incrementEntropy()
    else
        iLastMs = iTs
        for i = 1, iEntropyChars do
            tLastEntropy[i] = rand(0, 31)
        end
    end
    for i = 10, 1, -1 do
        tResult[i] = tBase32Map[iTs & 31]
        iTs = (iTs >> 5)
    end
    for i = 1, iEntropyChars do
        tResult[10 + i] = tBase32Map[tLastEntropy[i]]
    end
    return concat(tResult)
end

---`🔸 Client`<br>`🔹 Server`<br>
---Generate a random ULID
---@param xData? any @The data to bind to the ULID, defaults to `true`
---@return string @The generated ULID
function ULID.Generate(xData)
    local sULID
    repeat sULID = generateULID()
    until (__tULIDMap[sULID] == nil)

    __tULIDMap[sULID] = (xData ~= nil) and xData or true
    return sULID
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the ULID registry
---@return table<string, any> @The ULID registry
---@see ULID.Get
function ULID.GetTable()
    return __tULIDMap
end

---`🔸 Client`<br>`🔹 Server`<br>
---Return a value binded to the passed ULID
---@param sULID string @The ULID to search
---@return any @The value binded to the ULID, defaults to `true`
---@see ULID.GetTable
function ULID.Get(sULID)
    return __tULIDMap[sULID]
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the millisecond timestamp encoded in an ULID
---@param sULID string @The ULID to decode
---@return integer? @Millisecond timestamp, or nil if invalid
function ULID.GetTimestamp(sULID)
    if (type(sULID) ~= "string") or (#sULID ~= 10 + iEntropyChars) then return nil end
    local iTs = 0
    for i = 1, 10 do
        iTs = (iTs << 5) | (tBase32Decode[byte(sULID, i)] or 0)
    end
    return iTs
end

---`🔸 Client`<br>`🔹 Server`<br>
---Adds an ULID to the cache
---@param sULID string @The ULID to add
---@param xData? any @The data to bind to the ULID, defaults to `true`
---@see ULID.Clear
function ULID.Store(sULID, xData)
    if (type(sULID) ~= "string") or not sULID:IsULID() then return end
    __tULIDMap[sULID] = (xData ~= nil) and xData or true
end

---`🔸 Client`<br>`🔹 Server`<br>
---Removes the ULID from the cache
---@param sULID string @The ULID to remove<br>
---@see ULID.Store
function ULID.Clear(sULID)
    if (type(sULID) ~= "string") then return end
    __tULIDMap[sULID] = nil
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns wether the string is an ULID
---@param self string @The string to check
---@return boolean @Wether the string is an ULID
-- type guard is intentional: callable as string.IsULID(x) with non-string values
function string.IsULID(self)
    return (type(self) == "string") and (match(self, sULIDPattern) ~= nil)
end