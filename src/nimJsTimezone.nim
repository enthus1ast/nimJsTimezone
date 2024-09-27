# https://stackoverflow.com/questions/10087819/convert-date-to-another-timezone-in-javascript
# This looks very promising, can potentially replace chrono in the browser

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

function dateToString(date, timeZone) {
  date = convertTimeZone(date, 'UTC', timeZone)

  const year = date.getUTCFullYear().toString().padStart(4, '0')
  const month = (date.getUTCMonth() + 1).toString().padStart(2, '0')
  const day = date.getUTCDate().toString().padStart(2, '0')
  const hours = date.getUTCHours().toString().padStart(2, '0')
  const minutes = date.getUTCMinutes().toString().padStart(2, '0')
  const seconds = date.getUTCSeconds().toString().padStart(2, '0')

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


""".}
   
import chrono

proc fromTsToLocalImpl(ts: cfloat, tzName: cstring): cstring {.importc.}
proc fromLocalToTsImpl(dts: cstring, tzName: cstring): cfloat {.importc.}

proc fromTsToLocal*(ts: Timestamp, tzName: string): string =
  $fromTsToLocalImpl(ts.cfloat, tzName.cstring)

proc fromLocalToTs*(dts: string, tzName: string): Timestamp =
  fromLocalToTsImpl(dts.cstring, tzName.cstring).Timestamp()

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



      # echo fromTsToLocal(1727447681.039841.Timestamp(), "Europe/Berlin")
      # echo fromLocalToTs("2024-09-27 18:34:41", "Europe/Berlin")
      # echo fromLocalToTs("2024-09-27T18:34:41", "Europe/Berlin")
