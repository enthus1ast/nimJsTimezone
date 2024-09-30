# https://stackoverflow.com/questions/10087819/convert-date-to-another-timezone-in-javascript
# This looks very promising, can potentially replace chrono in the browser

when not defined(js) and not defined(nimsuggest):
  {.fatal: "Module nimJsTimezone is designed to be used with the JavaScript backend.".}

{.emit:"""

function convertTimeZone(
  date,
  timeZoneFrom, // default timezone is Local
  timeZoneTo, // default timezone is Local
) {
  const dateFrom = timeZoneFrom == null
    ? date
    : new Date(
      date.toLocaleString('en-US', {
        timeZone: timeZoneFrom,
      }),
    )

  const dateTo = timeZoneTo == null
    ? date
    : new Date(
      date.toLocaleString('en-US', {
        timeZone: timeZoneTo,
      }),
    )

  const result = new Date(date.getTime() + dateTo.getTime() - dateFrom.getTime())

  return result
}

function dateToString(date) {
  const year = date.getFullYear().toString().padStart(4, '0')
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  const seconds = date.getSeconds().toString().padStart(2, '0')

  return ``${year}-${month}-${day}T${hours}:${minutes}:${seconds}``
}

function fromTsToLocalImpl(ts, tzName) {
  // ts comes from nim's epochTime
  // ts is always UTC
  ts = ts * 1000
  return dateToString(convertTimeZone(new Date(ts), "UTC", tzName))
}

function fromLocalToTsImpl(dts, tzName) {
  return (convertTimeZone(new Date(dts), tzName, "UTC") / 1000)
}

function getAllTimezonesImpl() {
  return Intl.supportedValuesOf('timeZone');
}
""".}
   
import chrono

proc fromTsToLocalImpl(ts: cfloat, tzName: cstring): cstring {.importc.}
proc fromLocalToTsImpl(dts: cstring, tzName: cstring): cfloat {.importc.}

proc fromTsToLocal*(ts: Timestamp, tzName: string): string =
  $fromTsToLocalImpl(ts.cfloat, tzName.cstring)

proc fromTsToLocal*(ts: float, tzName: string): string =
  $fromTsToLocalImpl(ts.cfloat, tzName.cstring)

proc fromLocalToTs*(dts: string, tzName: string): Timestamp =
  fromLocalToTsImpl(dts.cstring, tzName.cstring).Timestamp()

proc getAllTimezonesImpl(): seq[cstring] {.importc}
proc getAllTimezones(): seq[string] =
  ## returns a list with all possible timezone values for your environment
  for tz in getAllTimezonesImpl():
    result.add $tz

when isMainModule and false:
  echo getAllTimezonesImpl()
  echo getAllTimezones()

when isMainModule:
  import unittest

  suite "browser timezone convert":
    test "back and forth":
      let tzName = "Europe/Berlin" 
      let ts = 1727447681.039841.Timestamp()
      let dts = fromTsToLocal(1727447681.039841.Timestamp(), tzName)
      let tsParsed = fromLocalToTs(dts, tzName)
      check ts.int == tsParsed.int

    test "back and forth two timezones":
      let tzName = "Europe/Berlin" 
      let tzName2 = "Asia/Jakarta" 

      let ts = 1727447681.039841.Timestamp()
      let dts = fromTsToLocal(1727447681.039841.Timestamp(), tzName)
      let dts2 = fromTsToLocal(1727447681.039841.Timestamp(), tzName2)

      let tsParsed = fromLocalToTs(dts, tzName)
      let tsParsed2 = fromLocalToTs(dts2, tzName2)
      check ts.int == tsParsed.int
      check ts.int == tsParsed2.int
      check tsParsed.int == tsParsed2.int

