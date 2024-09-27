```nim
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

```