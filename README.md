# δt 

A CLI that allows you to convert time from one time zone to another.

<kbd>dt</kbd> supports the following timezones

- wast: West African Standard Time
- et: Easter Time
- pt: Pacific Time
- ct: Central Time
- at: Atlantic Time
- ist: Indian Standard Tim

# How it works

To convert from `West African Standard Time` to `Indian Standard Time`, you can use the command: 

```shell
dt 10:30 wast ist
```

## Adding a timezone

Supported timezones and conversion values are hard-coded in the program and not read from an external source.
The timezones reside in a `StringHashMap`, akin to a `dict` in python or `object` in JavaScript.

```
try map.put("wast", 1);
try map.put("et", -4);
try map.put("pt", -7);
try map.put("ct", -5);
try map.put("at", -4);
try map.put("ist", 5.5);
```
The whole number represents hours while the fractional part is a fraction of 1 hour. So 0.5 is 30 minutes.

Adding a timezone will require you to add a key-value pair where the value is the time difference between the timezone and GMT.

