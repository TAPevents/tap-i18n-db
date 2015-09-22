Fiber = Npm.require('fibers')

share.i18nCollectionExtensions = (obj) ->
  obj.i18nFind = (selector, options) ->
    current_language = Fiber.current.language_tag

    if typeof current_language == "undefined"
      throw new Meteor.Error(500, "TAPi18n.i18nFind should be called only from TAPi18n.publish functions")

    if _.isUndefined selector
      selector = {}

    dialect_of = share.helpers.dialectOf current_language
    collection_base_language = @._base_language

    supported_languages = TAPi18n.conf.supported_languages || Object.keys TAPi18n.getLanguages()
    if current_language? and not (current_language in supported_languages)
      throw new Meteor.Error(400, "Not supported language")

    if not options?
      options = {}
    original_fields = options.fields || {}
    i18n_fields = _.extend {}, original_fields

    if not _.isEmpty(i18n_fields)
      # determine the projection kind
      # note that we don't need to address the case where {_id: 0}, since _id: 0
      # is not allowed for cursors returned from a publish function
      delete i18n_fields._id
      white_list_projection = _.first(_.values i18n_fields) == 1
      if "_id" of original_fields
        i18n_fields["_id"] = original_fields["_id"]

      if white_list_projection
        if lang != null
          for lang in supported_languages
            if lang != collection_base_language and ((lang == current_language) or (lang == dialect_of))
              for field of original_fields
                if field != "_id" and not ("." in field)
                  i18n_fields["i18n.#{lang}.#{field}"] = 1
      else
        # black list
        if current_language == null
          i18n_fields.i18n = 0
        else
          for lang in supported_languages
            if lang != collection_base_language
              if lang != current_language and lang != dialect_of
                i18n_fields["i18n.#{lang}"] = 0
              else
                for field of original_fields
                  if field != "_id" and not ("." in field)
                    i18n_fields["i18n.#{lang}.#{field}"] = 0
    else
      if current_language == null
        i18n_fields.i18n = 0
      else
        for lang in supported_languages
          if lang != collection_base_language and lang != current_language and lang != dialect_of
            i18n_fields["i18n.#{lang}"] = 0

    return @.find(selector, _.extend({}, options, {fields: i18n_fields}))

  return obj

TAPi18n.publish = (name, handler, options) ->
  if name is null
    throw new Meteor.Error(500, "TAPi18n.publish doesn't support null publications")

  i18n_handler = () ->
    args = Array.prototype.slice.call(arguments)

    # last subscription argument is always the language tag
    language_tag = _.last(args)
    @.language = language_tag
    # Set handler context in current fiber's
    Fiber.current.language_tag = language_tag
    # Call the user handler without the language_tag argument
    cursors = handler.apply(@, args.slice(0, -1))
    # Clear handler context
    delete Fiber.current.language_tag

    if cursors?
      return cursors

  # set the actual publish method
  return Meteor.publish(name, i18n_handler, options)
