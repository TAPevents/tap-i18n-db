TAPi18n.Collection = (name, options={}) ->
  # Set the transform option
  if Meteor.isClient
    original_transform = options.transform or (doc) -> doc
    options.transform = (doc) ->
      share.i18nCollectionTransform(original_transform(doc), collection)

  collection = share.i18nCollectionExtensions(commonCollectionExtensions(new Meteor.Collection(name, options)))

  collection._base_language = if "base_language" of options then options["base_language"] else globals.fallback_language

  return collection

share.helpers = {}
share.helpers.dialectOf = (lang) ->
  if lang? and "-" in lang
    return lang.replace(/-.*/, "")
  return null

share.helpers.removeTrailingUndefs = (arr) ->
  while (not _.isEmpty arr) and (_.isUndefined _.last arr)
    arr.pop()
  return arr

removeTrailingUndefs = share.helpers.removeTrailingUndefs

commonCollectionExtensions = (obj) ->
  reportError = (error, attempted_operation, callback) ->
    if _.isFunction callback
      Meteor.setTimeout (-> callback(error, false)), 0
    else
      console.log "#{attempted_operation} failed: #{error.reason}"

    return error

  throwError = (error, attempted_operation, callback) ->
    throw reportError(error, attempted_operation, callback)

  verifyI18nEnabled = (attempted_operation, callback) ->
    if TAPi18n._enabled()
      return

    throwError new Meteor.Error(400, "TAPi18n is not supported"), attempted_operation, callback

  isSupportedLanguage = (lang, attempted_operation, callback) ->
    if lang in TAPi18n.conf.supported_languages
      return

    throwError new Meteor.Error(400, "Not supported language: #{lang}"), attempted_operation, callback

  getLanguageOrEnvLanguage = (language_tag, attempted_operation, callback) ->
    # if no language_tag & isClient, try to get env lang
    if Meteor.isClient
      if not language_tag?
        language_tag = TAPi18n.getLanguage()

    if language_tag?
      return language_tag

    throwError new Meteor.Error(400, "Missing language_tag"), attempted_operation, callback

  obj.insertTranslations = (doc, translations, callback) ->
    try
      verifyI18nEnabled("insert", callback)
    catch
      return null

    doc = _.extend {}, doc
    translations = _.extend {}, translations

    if translations?
      for lang of translations
        # make sure all languages in translations are supported
        try
          isSupportedLanguage lang, "insert", callback
        catch
          return null

        # merge base language's fields with regular fields
        if lang == @._base_language
          doc = _.extend doc, translations[lang]

          delete translations[lang]

      if not _.isEmpty translations
        doc = _.extend doc, {i18n: translations}

    @.insert.apply @, removeTrailingUndefs([doc, callback])

  obj.updateTranslations = (selector, translations, options, callback) ->
    if _.isFunction options
      callback = options
      options = undefined

    try
      verifyI18nEnabled("update", callback)
    catch
      return null

    updates = {}

    if translations?
      for lang of translations
        # make sure all languages in translations are supported
        try
          isSupportedLanguage lang, "update", callback
        catch
          return null

        # treat base language's fields as regular fields
        if lang == @._base_language
          _.extend updates, translations[lang]
        else
          _.extend updates, _.object(_.map(translations[lang], ((val, field) -> ["i18n.#{lang}.#{field}", val])))

    @.update.apply @, removeTrailingUndefs([selector, {$set: updates}, options, callback])

  obj.removeTranslations = (selector, fields, options, callback) ->
    if _.isFunction options
      callback = options
      options = undefined

    try
      verifyI18nEnabled("remove translations", callback)
    catch
      return null

    if not fields?
      reportError new Meteor.Error(400, "Missing arugment: fields"), "remove translations", callback
      return null

    if not _.isArray fields
      reportError new Meteor.Error(400, "fields argument should be an array"), "remove translations", callback
      return null

    updates = {}

    for field in fields
      lang = _.first field.split(".")

      if lang is '*'
        field = field.replace('*', '')
        _.each TAPi18n.conf.supported_languages, ( lang ) ->
          updates["i18n.#{lang}#{field}"] = ''
      else
        # make sure all languages are supported
        try
          isSupportedLanguage lang, "remove translations", callback
        catch
          return null

        # treat base language's fields as regular fields
        if lang == @._base_language
          field = field.replace("#{lang}.", "")
          if field == @._base_language
            reportError new Meteor.Error(400, "Complete removal of collection's base language from a document is not permitted"), "remove translations", callback
            return null

          updates[field] = ""
        else
          updates["i18n.#{field}"] = ""

    @.update.apply @, removeTrailingUndefs([selector, {$unset: updates}, options, callback])

  obj.insertLanguage = (doc, translations, language_tag, callback) ->
    try
      verifyI18nEnabled("insert", callback)
    catch
      return null

    # in case language_tag omitted
    if _.isFunction language_tag
      callback = language_tag
      language_tag = undefined

    try
      language_tag = getLanguageOrEnvLanguage language_tag, "insert", callback
    catch
      return null

    _translations = {}
    _translations[language_tag] = translations

    @.insertTranslations(doc, _translations, callback)

  obj.updateLanguage = (selector, translations) ->
    try
      verifyI18nEnabled("update", callback)
    catch
      return null

    language_tag = options = callback = undefined

    args = _.toArray arguments
    for arg in args.slice(2)
      if _.isFunction arg
        callback = arg
        break
      else if _.isObject arg
        options = arg
      else if _.isUndefined(options) and _.isString(arg)
        # language_tag can't come after options
        language_tag = arg

    try
      language_tag = getLanguageOrEnvLanguage language_tag, "update", callback
    catch
      return null

    _translations = {}
    _translations[language_tag] = translations

    @updateTranslations(selector, _translations, options, callback)

  # Alias
  obj.translate = obj.updateLanguage

  obj.removeLanguage = (selector, fields) ->
    try
      verifyI18nEnabled("remove translations", callback)
    catch
      return null

    language_tag = options = callback = undefined

    args = _.toArray arguments
    for arg in args.slice(2)
      if _.isFunction arg
        callback = arg
        break
      else if _.isObject arg
        options = arg
      else if _.isUndefined(options) and _.isString(arg)
        # language_tag can't come after options
        language_tag = arg

    try
      language_tag = getLanguageOrEnvLanguage language_tag, "remove", callback
    catch
      return null

    if fields isnt null and not _.isArray fields
      reportError new Meteor.Error(400, "fields argument should be an array"), "remove translations", callback
      return null

    if fields is null
      # remove entire language
      _fields_to_remove = ["#{language_tag}"]
    else
      _fields_to_remove = _.map fields, (field) -> "#{language_tag}.#{field}"

    @removeTranslations(selector, _fields_to_remove, options, callback)

  return obj
