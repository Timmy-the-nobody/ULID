Notes:
This was made for [nanos world™](https://store.steampowered.com/app/1841660/), if you plan to use it outside you'll have to make some tweaks to the library

### ULID.Clear

`🔸 Client`<br>`🔹 Server`<br>
Removes the ULID from the cache

@*param* `sULID` — The ULID to remove<br>

```lua
function ULID.Clear(sULID: string)
```


---

### ULID.Generate

`🔸 Client`<br>`🔹 Server`<br>
Generate a random ULID

@*param* `xData` — The data to bind to the ULID, defaults to `true`

@*return* — The generated ULID

```lua
function ULID.Generate(xData?: any)
  -> string
```


---

### ULID.Get

`🔸 Client`<br>`🔹 Server`<br>
Return a value binded to the passed ULID

@*param* `sULID` — The ULID to search

@*return* — The value binded to the ULID, defaults to `true`

```lua
function ULID.Get(sULID: string)
  -> any
```


---

### ULID.GetTable

`🔸 Client`<br>`🔹 Server`<br>
Returns the ULID registry

@*return* — The ULID registry

```lua
function ULID.GetTable()
  -> table<string, ULID>
```


---

### ULID.Store

`🔸 Client`<br>`🔹 Server`<br>
Adds an ULID to the cache

@*param* `sULID` — The ULID to add

@*param* `xData` — The data to bind to the ULID, defaults to `true`

```lua
function ULID.Store(sULID: string, xData?: any)
```
