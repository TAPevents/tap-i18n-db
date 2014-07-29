share.lpad = (value, padding) ->
  zeroes = "0"
  zeroes += "0" for i in [1..padding]
  (zeroes + value).slice(padding * -1)

share.once = (cb) ->
  () ->
    if not cb.once?
      cb.once = true
      cb()

share.dialectOf = (lang) ->
  if lang? and "-" in lang
    return lang.replace(/-.*/, "")
  return null

share.now = () ->
  new Date().getTime()
