test_collections = share.test_collections
translations_editing_tests_collection = share.translations_editing_tests_collection
idle_time = 2000
once = share.once



Tinytest.add 'tap-i18n-db - translations editing - insertTranslations - valid test', (test) ->
  test.equal \
    translations_editing_tests_collection.findOne(_id = translations_editing_tests_collection.insertTranslations({a: 1, b: 5}, {aa: {c: 3}, en: {b: 2, d: 4}}), {transform: null}),
    {a: 1, b: 2, d: 4, i18n: {aa: {c: 3}}, _id: _id}

Tinytest.add 'tap-i18n-db - translations editing - insertTranslations - no translations', (test) ->
  test.equal \
    translations_editing_tests_collection.findOne(_id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2}), {transform: null}),
    {a: 1, b: 2, _id: _id}

Tinytest.addAsync 'tap-i18n-db - translations editing - insertTranslations - unsupported lang', (test, onComplete) ->
  result = translations_editing_tests_collection.insertTranslations {a: 1, b: 2}, {ru: {c: 3}},
             (err, id) ->
               test.isFalse id
               test.instanceOf err, Meteor.Error
               test.equal err.reason, "Not supported language: ru"
               test.isNull(result)

               onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - insertLanguage - language: collection\'s base language', (test, onComplete) ->
  translations_editing_tests_collection.insertLanguage {a: 1, b: 5}, {b: 2, d: 4}, "en",
    (err, id) ->
      test.equal \
        translations_editing_tests_collection.findOne(id, {transform: null}),
        {a: 1, b: 2, d: 4, _id: id}
      onComplete()

Tinytest.add 'tap-i18n-db - translations editing - insertLanguage - language: not collection\'s base language', (test) ->
  test.equal \
    translations_editing_tests_collection.findOne(_id = translations_editing_tests_collection.insertLanguage({a: 1, b: 5}, {b: 2, d: 4}, "aa"), {transform: null}),
    {a: 1, b: 5, i18n: {aa: {b: 2, d: 4}}, _id: _id}

Tinytest.addAsync 'tap-i18n-db - translations editing - insertLanguage - language: not supported language', (test, onComplete) ->
  result = translations_editing_tests_collection.insertLanguage {a: 1, b: 5}, {b: 2, d: 4}, "ru",
             (err, id) ->
               test.isFalse id
               test.instanceOf err, Meteor.Error
               test.equal err.reason, "Not supported language: ru"
               test.isNull(result)

               onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - insertLanguage - language: not specified', (test, onComplete) ->
  result = translations_editing_tests_collection.insertLanguage {a: 1, b: 5}, {b: 2, d: 4},
             (err, id) ->
               test.isFalse id
               test.instanceOf err, Meteor.Error
               test.equal err.reason, "Missing language_tag"
               test.isNull(result)

               onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - updateTranslations - valid update', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 5, b: 6}, {aa: {x: 4, y: 5}, "aa-AA": {l: 1, m: 2}})
  result = translations_editing_tests_collection.updateTranslations _id, {en: {a: 1}, aa: {x: 1}}
  result = translations_editing_tests_collection.updateTranslations _id, {en: {b: 2, c: 3}, aa: {y: 2, z: 3}, "aa-AA": {n: 3}}
  test.equal result, 1, "Correct number of affected documents"
  test.equal \
    translations_editing_tests_collection.findOne(_id, {transform: null}),
    {a: 1, b: 2, c: 3, i18n: {aa: {x: 1, y: 2, z: 3}, "aa-AA": {l: 1, m: 2, n: 3}}, _id: _id}
  onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - updateTranslations - empty update', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1}, {aa: {x: 1}})
  result = translations_editing_tests_collection.updateTranslations _id
  test.equal \
    translations_editing_tests_collection.findOne(_id, {transform: null}),
    {a: 1, i18n: {aa: {x: 1}}, _id: _id}
  test.equal result, 1, "Correct number of affected documents"
  onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - updateTranslations - unsupported lang', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1}, {aa: {x: 1}})
  result = translations_editing_tests_collection.updateTranslations _id, {ru: {c: 3}},
             (err, id) ->
               test.isFalse id
               test.instanceOf err, Meteor.Error
               test.equal err.reason, "Not supported language: ru"
               test.isNull(result)

               onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - translate - valid update', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 5, b: 2}, {aa: {x: 4, y: 2}})
  result = translations_editing_tests_collection.translate _id, {a: 1, c: 3}, "en"
  test.equal result, 1, "Correct number of affected documents"
  result = translations_editing_tests_collection.translate _id, {x: 1, z: 3}, "aa", {}
  test.equal result, 1, "Correct number of affected documents"
  result = translations_editing_tests_collection.translate _id, {l: 1, m: 2, n: 3}, "aa-AA", {}, (err, affected_rows) ->
    Meteor.setTimeout (->
      test.equal 1, affected_rows
      test.equal \
        translations_editing_tests_collection.findOne(_id, {transform: null}),
        {a: 1, b: 2, c: 3, i18n: {aa: {x: 1, y: 2, z: 3}, "aa-AA": {l: 1, m: 2, n: 3}}, _id: _id}
      onComplete()
    ), 1000

Tinytest.add 'tap-i18n-db - translations editing - remove translation - valid remove', (test) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
  result = translations_editing_tests_collection.removeTranslations _id, ["en.a", "aa.y", "aa-AA"] # remove some fields and the entire AA-aa lang
  test.equal result, 1, "Correct number of affected documents"
  result = translations_editing_tests_collection.removeTranslations _id, [], {} # remove nothing
  test.equal result, 1, "Correct number of affected documents"
  test.equal \
    translations_editing_tests_collection.findOne(_id, {transform: null}),
    {b: 2, i18n: {aa: {x: 1}}, _id: _id}

Tinytest.addAsync 'tap-i18n-db - translations editing - remove translation - attempt to remove base language', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
  result = translations_editing_tests_collection.removeTranslations _id, ["en"],
             (err, affected_rows) ->
               test.isFalse affected_rows
               test.instanceOf err, Meteor.Error
               test.equal err.reason, "Complete removal of collection's base language from a document is not permitted"
               test.isNull(result)

               onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - remove translation - fields argument is not an array', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
  result = translations_editing_tests_collection.removeTranslations _id, {},
             (err, affected_rows) ->
               test.isFalse affected_rows
               test.instanceOf err, Meteor.Error
               test.isNull(result)

               onComplete()

Tinytest.addAsync 'tap-i18n-db - translations editing - remove language - valid remove', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2, c: 3}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
  result = translations_editing_tests_collection.removeLanguage _id, ["a", "c"], "en" # remove some fields - base lang
  test.equal result, 1, "Correct number of affected documents"
  result = translations_editing_tests_collection.removeLanguage _id, ["x"], "aa", {}, (err, affected_rows) -> # remove some fields - general lang
    test.equal affected_rows, 1, "Correct number of affected documents"
  result = translations_editing_tests_collection.removeLanguage _id, [], "aa" # remove nothing - general lang
  test.equal result, 1, "Correct number of affected documents"
  result = translations_editing_tests_collection.removeLanguage _id, null, "aa-AA", (err, affected_rows) -> # remove entire language
    Meteor.setTimeout (->
      test.equal affected_rows, 1, "Correct number of affected documents"

      test.equal \
        translations_editing_tests_collection.findOne(_id, {transform: null}),
        {b: 2, i18n: {aa: {y: 2}}, _id: _id}

      onComplete()
    )

Tinytest.addAsync 'tap-i18n-db - translations editing - remove language - attempt to remove base language', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2, c: 3}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
  translations_editing_tests_collection.removeLanguage _id, null, "en", (err, affected_rows) ->
    Meteor.setTimeout (->
      test.isFalse affected_rows
      test.instanceOf err, Meteor.Error
      test.equal err.reason, "Complete removal of collection's base language from a document is not permitted"

      onComplete()
    )

Tinytest.addAsync 'tap-i18n-db - translations editing - remove language - fields argument is not an array', (test, onComplete) ->
  _id = translations_editing_tests_collection.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
  result = translations_editing_tests_collection.removeLanguage _id, {}, "aa",
             (err, affected_rows) ->
               test.isFalse affected_rows
               test.instanceOf err, Meteor.Error
               test.isNull(result)

               onComplete()

if Meteor.isServer
  Tinytest.add 'tap-i18n-db - TAPi18n.i18nFind works only from TAPi18n.publish', (test) ->
    test.throws (-> test_collections.a.i18nFind()), "TAPi18n.i18nFind should be called only from TAPi18n.publish functions"

if Meteor.isClient
  document.title = "UnitTest: tap-i18n-db used in a tap-i18n enabled project"

  supported_languages = _.keys TAPi18n.getLanguages()

  max_document_id = share.max_document_id

  get_general_classed_collections = (class_suffix="") ->
    remap_results = (results) ->
      # remap the results object so the keys will be value of the result's key field
      _.reduce _.values(results), ((a, b) -> a[b.id] = b; a), {}
  
    collections_docs = [
      remap_results test_collections["a#{class_suffix}"].find({}, {sort: {"id": 1}}).fetch()
      remap_results test_collections["b#{class_suffix}"].find({}, {sort: {"id": 1}}).fetch()
      remap_results test_collections["c#{class_suffix}"].find({}, {sort: {"id": 1}}).fetch()
    ]
  
    docs = []
  
    for i in [0...max_document_id]
      if i of collections_docs[i % 3]
        if collections_docs[i % 3][i]?
          docs.push(collections_docs[i % 3][i])
  
    return docs
  
  get_basic_collections_docs = () ->
    get_general_classed_collections()
  
  get_regular_base_language_collections_docs = () ->
    get_general_classed_collections("_aa")
  
  get_dialect_base_language_collections_docs = () ->
    get_general_classed_collections("_aa-AA")
  
  get_all_docs = () ->
    basic = get_basic_collections_docs()
    regular_lang = get_regular_base_language_collections_docs()
    dialect = get_dialect_base_language_collections_docs()
    all = [].concat(basic, regular_lang, dialect)
  
    return {basic: basic, regular_lang: regular_lang, dialect: dialect, all: all}
  
  subscription_a = subscription_b = subscription_c = null
  
  stop_all_subscriptions = () ->
    for i in [subscription_a,  subscription_b,  subscription_c]
      if i?
        i.stop()
    Deps.flush() # force the cleanup of the minimongo collections
  
  subscribe_simple_subscriptions = () ->
    stop_all_subscriptions()
  
    a_dfd = new $.Deferred()
    subscription_a = TAPi18n.subscribe "class_a", {onReady: (() -> a_dfd.resolve()), onError: ((error) -> a_dfd.reject())}
    b_dfd = new $.Deferred()
    subscription_b = TAPi18n.subscribe "class_b", {onReady: (() -> b_dfd.resolve()), onError: ((error) -> b_dfd.reject())}
    c_dfd = new $.Deferred()
    subscription_c = TAPi18n.subscribe "class_c", {onReady: (() -> c_dfd.resolve()), onError: ((error) -> c_dfd.reject())}
  
    return [[subscription_a, subscription_b, subscription_c], [a_dfd, b_dfd, c_dfd]]
  
  subscribe_complex_subscriptions = () ->
    stop_all_subscriptions()
  
    language_to_exclude_from_class_a_and_b =
      supported_languages[(supported_languages.indexOf(TAPi18n.getLanguage()) + 1) % supported_languages.length]
  
    # class_a - inclusive projection - all properties but language_to_exclude_from_class_a_and_b
    a_dfd = new $.Deferred()
    projection = {_id: 1, id: 1}
  
    for language in supported_languages
      if language != language_to_exclude_from_class_a_and_b
        projection["not_translated_to_#{language}"] = 1
  
    subscription_a = TAPi18n.subscribe "class_a", projection, {onReady: (() -> a_dfd.resolve()), onError: ((error) -> a_dfd.reject())}
  
    b_dfd = new $.Deferred()
    projection = {_id: 1} # _id: 1, just to make a bit more complex, should behave just the same
    projection["not_translated_to_#{language_to_exclude_from_class_a_and_b}"] = 0
    subscription_b = TAPi18n.subscribe "class_b", projection, {onReady: (() -> b_dfd.resolve()), onError: ((error) -> b_dfd.reject())}
  
    c_dfd = new $.Deferred()
    projection = {_id: 1} # _id: 1, just to make a bit more complex, should behave just the same
    projection["not_translated_to_#{TAPi18n.getLanguage()}"] = 0
    subscription_c = TAPi18n.subscribe "class_c", projection, {onReady: (() -> c_dfd.resolve()), onError: ((error) -> c_dfd.reject())}
  
    return [[subscription_a, subscription_b, subscription_c], [a_dfd, b_dfd, c_dfd]]
  
  validate_simple_subscriptions_documents = (test, subscriptions, documents) ->
    current_language = TAPi18n.getLanguage()
    i18n_supported = current_language?

    base_language_by_collection_type = {
      basic: test_collections.a._base_language
      regular_lang: test_collections.a_aa._base_language
      dialect: test_collections["a_aa-AA"]._base_language
    }
  
    for collection_type of base_language_by_collection_type
      collection_base_language = base_language_by_collection_type[collection_type]
  
      collection_type_documents = documents[collection_type]
  
      _.each collection_type_documents, (doc) ->
        for language_property_not_translated_to in supported_languages
          should_translate_to = current_language
          if should_translate_to == null
            should_translate_to = collection_base_language
          should_translate_to_dialect_of = share.dialectOf should_translate_to

          property = "not_translated_to_#{language_property_not_translated_to}"
          value = doc[property]

          if should_translate_to != language_property_not_translated_to
            expected_value = "#{property}-#{should_translate_to}-#{doc.id}"
          else
            if i18n_supported
              if should_translate_to_dialect_of?
                expected_value = "#{property}-#{should_translate_to_dialect_of}-#{doc.id}"
              else if collection_base_language != should_translate_to
                expected_value = "#{property}-#{collection_base_language}-#{doc.id}"
              else
                expected_value = undefined
            else
              expected_value = undefined

          test.equal expected_value, value
  
  validate_complex_subscriptions_documents = (test, subscriptions, documents) ->
    current_language = TAPi18n.getLanguage()
    i18n_supported = current_language?

    base_language_by_collection_type = {
      basic: test_collections.a._base_language
      #regular_lang: test_collections.a_aa._base_language
      #dialect: test_collections["a_aa-AA"]._base_language
    }
  
    for collection_type of base_language_by_collection_type
      collection_base_language = base_language_by_collection_type[collection_type]
      collection_type_documents = documents[collection_type]
  
      _.each collection_type_documents, (doc) ->
        language_excluded_from_class_a_and_b =
          supported_languages[(supported_languages.indexOf(current_language) + 1) % supported_languages.length]
        field_excluded_from_doc = null
        switch doc.id % 3
          when 0 then field_excluded_from_doc = language_excluded_from_class_a_and_b
          when 1 then field_excluded_from_doc = language_excluded_from_class_a_and_b
          when 2 then field_excluded_from_doc = current_language

        for language_property_not_translated_to in supported_languages
          should_translate_to = current_language
          if should_translate_to == null
            should_translate_to = collection_base_language
          should_translate_to_dialect_of = share.dialectOf should_translate_to

          property = "not_translated_to_#{language_property_not_translated_to}"
          value = doc[property]

          if language_property_not_translated_to == field_excluded_from_doc
            expected_value = undefined
          else if should_translate_to != language_property_not_translated_to
            expected_value = "#{property}-#{should_translate_to}-#{doc.id}"
          else
            if i18n_supported
              if should_translate_to_dialect_of?
                expected_value = "#{property}-#{should_translate_to_dialect_of}-#{doc.id}"
              else if collection_base_language != should_translate_to
                expected_value = "#{property}-#{collection_base_language}-#{doc.id}"
              else
                expected_value = undefined
            else
              expected_value = undefined

          test.equal expected_value, value, "col_type=#{collection_type}, property=#{property}"

  general_tests = (test, subscriptions, documents) ->
    test.equal documents.all.length, max_document_id * 3, "Expected documents count in collections"
  
    test.isTrue (_.reduce (_.map documents.all, (doc) -> (not doc.i18n?)), ((memo, current) -> memo and current), true), "The subdocument i18n is not part of the documents"
  
  null_language_tests = (test, subscriptions, documents) ->
    return
  
  Tinytest.addAsync 'tap-i18n-db - language: null; simple pub/sub - general tests', (test, onComplete) ->
    subscriptions = subscribe_simple_subscriptions()

    test_case = once () ->
      documents = get_all_docs()

      general_tests(test, subscriptions, documents)

      null_language_tests(test, subscriptions, documents)

      validate_simple_subscriptions_documents(test, subscriptions, documents)

      onComplete()

    Deps.autorun () ->
      if subscription_a.ready() and subscription_b.ready() and subscription_c.ready()
        test_case()

  if not Package.autopublish?
    Tinytest.addAsync 'tap-i18n-db - language: null; complex pub/sub - general tests', (test, onComplete) ->
      subscriptions = subscribe_complex_subscriptions()

      test_case = once () ->
        documents = get_all_docs()

        general_tests(test, subscriptions, documents)

        null_language_tests(test, subscriptions, documents)

        validate_complex_subscriptions_documents(test, subscriptions, documents)

        onComplete()

      Deps.autorun () ->
        if subscription_a.ready() and subscription_b.ready() and subscription_c.ready()
          test_case()

  Tinytest.addAsync 'tap-i18n-db - language: en; simple pub/sub - general tests', (test, onComplete) ->
    TAPi18n.setLanguage("en")
      .done () ->
        subscriptions = subscribe_simple_subscriptions()

        $.when.apply(this, subscriptions[1])
          .done ->
            documents = get_all_docs()

            general_tests(test, subscriptions, documents)

            validate_simple_subscriptions_documents(test, subscriptions, documents)

            onComplete()

  if not Package.autopublish?
    Tinytest.addAsync 'tap-i18n-db - language: en; complex pub/sub - general tests', (test, onComplete) ->
      TAPi18n.setLanguage("en")
        .done () ->
          subscriptions = subscribe_complex_subscriptions()

          $.when.apply(this, subscriptions[1])
            .done ->
              documents = get_all_docs()

              general_tests(test, subscriptions, documents)

              validate_complex_subscriptions_documents(test, subscriptions, documents)

              onComplete()

  Tinytest.addAsync 'tap-i18n-db - language: aa; simple pub/sub - general tests', (test, onComplete) ->
    TAPi18n.setLanguage("aa")
      .done () ->
        subscriptions = subscribe_simple_subscriptions()

        $.when.apply(this, subscriptions[1])
          .done ->
            documents = get_all_docs()

            general_tests(test, subscriptions, documents)

            validate_simple_subscriptions_documents(test, subscriptions, documents)

            onComplete()

  if not Package.autopublish?
    Tinytest.addAsync 'tap-i18n-db - language: aa; complex pub/sub - general tests', (test, onComplete) ->
      TAPi18n.setLanguage("aa")
        .done () ->
          subscriptions = subscribe_complex_subscriptions()

          $.when.apply(this, subscriptions[1])
            .done ->
              documents = get_all_docs()

              general_tests(test, subscriptions, documents)

              validate_complex_subscriptions_documents(test, subscriptions, documents)

              onComplete()

  Tinytest.addAsync 'tap-i18n-db - language: aa-AA; simple pub/sub - general tests', (test, onComplete) ->
    TAPi18n.setLanguage("aa-AA")
      .done () ->
        subscriptions = subscribe_simple_subscriptions()

        $.when.apply(this, subscriptions[1])
          .done ->
            documents = get_all_docs()

            general_tests(test, subscriptions, documents)

            validate_simple_subscriptions_documents(test, subscriptions, documents)

            onComplete()

  if not Package.autopublish?
    Tinytest.addAsync 'tap-i18n-db - language: aa-AA; complex pub/sub - general tests', (test, onComplete) ->
      TAPi18n.setLanguage("aa-AA")
        .done () ->
          subscriptions = subscribe_complex_subscriptions()

          $.when.apply(this, subscriptions[1])
            .done ->
              documents = get_all_docs()

              general_tests(test, subscriptions, documents)

              validate_complex_subscriptions_documents(test, subscriptions, documents)

              onComplete()

  Tinytest.addAsync 'tap-i18n-db - subscribing with a not-supported language fails', (test, onComplete) ->
    dfd = new $.Deferred()
    Meteor.subscribe "class_a", "gg-GG",
      onReady: () ->
        dfd.reject()
      onError: (e) ->
        test.equal 400, e.error
        test.equal "Not supported language", e.reason
        dfd.resolve(e)

    dfd
      .fail () ->
        test.fail("Subscriptions that should have failed succeeded")
      .always () ->
        onComplete()

  Tinytest.addAsync 'tap-i18n-db - reactivity test - simple subscription', (test, onComplete) ->
    TAPi18n.setLanguage supported_languages[0]

    subscriptions = subscribe_simple_subscriptions()

    comp = null
    documents = null
    testRunner = null

    testFunc = -> _.defer ->
      console.log "Testing simple subscriptions' reactivity: language=#{TAPi18n.getLanguage()}"

      # test
      general_tests(test, subscriptions, documents)

      validate_simple_subscriptions_documents(test, subscriptions, documents)

      lang_id = supported_languages.indexOf(TAPi18n.getLanguage())
      if lang_id + 1 < supported_languages.length
        # switch language
        testRunner = _.once testFunc
        TAPi18n.setLanguage supported_languages[lang_id + 1]
      else
        # stop
        comp.stop()
        onComplete()

    testRunner = _.once testFunc

    comp = Deps.autorun ->
      documents = get_all_docs()

      if _.every(subscriptions[0], (sub) => sub.ready())
        testRunner()
      
  if not Package.autopublish?
    Tinytest.addAsync 'tap-i18n-db - reactivity test - complex subscription', (test, onComplete) ->
      stop_all_subscriptions()

      fields_to_exclude = ["not_translated_to_en", "not_translated_to_aa", "not_translated_to_aa-AA"]
      testCases = [];
      _.each supported_languages, (language) ->
        _.each fields_to_exclude, (field_to_exclude) ->
          _.times 2, (projection_type) ->
            testCases.push
              projection_type: projection_type
              field_to_exclude: field_to_exclude
              language: language

      local_session = new ReactiveDict()

      shiftTest = ->
        oneTest = testCases.shift()
        if oneTest
          local_session.set "field_to_exclude", oneTest.field_to_exclude
          local_session.set "projection_type", oneTest.projection_type
          TAPi18n.setLanguage oneTest.language
        oneTest
      
      shiftTest();

      fields = null
      subscriptions = null
      documents = null
      comp = null
      testRunner = null

      testFunc = -> _.defer ->
        console.log "Testing complex subscriptions' reactivity: language=#{TAPi18n.getLanguage()}; field_to_exclude=#{local_session.get("field_to_exclude")}; projection_type=#{if local_session.get("projection_type") then "inclusive" else "exclusive"}; projection=#{JSON.stringify fields}"

        # test
        general_tests(test, subscriptions, documents)

        documents.all.forEach (doc) ->
          test.isUndefined doc[local_session.get("field_to_exclude")]

        testRunner = _.once testFunc

        if !shiftTest()
          # stop
          comp.stop()
          onComplete()
      testRunner = _.once testFunc

      Deps.autorun ->
        field_to_exclude = local_session.get("field_to_exclude")
        fields = {}
        if local_session.get("projection_type") == 0
          fields[field_to_exclude] = 0
        else
          for field in fields_to_exclude
            if field != field_to_exclude
              fields[field] = 1
          fields["id"] = 1

        a_dfd = new $.Deferred()
        subscription_a = TAPi18n.subscribe "class_a", fields, {onReady: (() -> a_dfd.resolve()), onError: ((error) -> a_dfd.reject())}
        b_dfd = new $.Deferred()
        subscription_b = TAPi18n.subscribe "class_b", fields, {onReady: (() -> b_dfd.resolve()), onError: ((error) -> b_dfd.reject())}
        c_dfd = new $.Deferred()
        subscription_c = TAPi18n.subscribe "class_c", fields, {onReady: (() -> c_dfd.resolve()), onError: ((error) -> c_dfd.reject())}

        subscriptions = [[subscription_a, subscription_b, subscription_c], [a_dfd, b_dfd, c_dfd]]

      comp = Deps.autorun ->
        documents = get_all_docs()
        # include reactive dict to invalidate tracker 
        local_session.get("projection_type")
        local_session.get("field_to_exclude")
        if _.every(subscriptions[0], (sub) => sub.ready())
          testRunner()

# Translations editing tests that require env language != null
if Meteor.isClient
  Tinytest.addAsync 'tap-i18n-db - translations editing - insertLanguage - language_tag=TAPi18n.getLanguage()', (test, onComplete) ->
    TAPi18n.setLanguage("aa")
      .done ->
        test.equal \
          translations_editing_tests_collection.findOne(_id = translations_editing_tests_collection.insertLanguage({a: 1, b: 5}, {b: 2, d: 4}, (-> onComplete())), {transform: null}, {transform: null}),
          {a: 1, b: 5, i18n: {aa: {b: 2, d: 4}}, _id: _id}

  Tinytest.addAsync 'tap-i18n-db - translations editing - translate - language_tag=TAPi18n.getLanguage()', (test, onComplete) ->
    TAPi18n.setLanguage("aa")
      .done ->
        _id = translations_editing_tests_collection.insertTranslations({a: 5, b: 2}, {aa: {x: 4, y: 2}})
        result = translations_editing_tests_collection.translate _id, {a: 1, c: 3}
        test.equal result, 1, "Correct number of affected documents"
        result = translations_editing_tests_collection.translate _id, {x: 1, z: 3}, {}
        test.equal result, 1, "Correct number of affected documents"
        result = translations_editing_tests_collection.translate _id, {l: 1, m: 2}, (err, affected_rows) ->
          Meteor.setTimeout (->
            test.equal 1, affected_rows
            test.equal \
              translations_editing_tests_collection.findOne(_id, {transform: null}),
              {a: 5, b: 2, i18n: {aa: {a: 1, c: 3, x: 1, y: 2, z: 3, l: 1, m: 2}}, _id: _id}
            onComplete()
          ), 1000

  Tinytest.addAsync 'tap-i18n-db - translations editing - removeLanguage - language_tag=TAPi18n.getLanguage()', (test, onComplete) ->
    TAPi18n.setLanguage("aa")
      .done ->
        _id = translations_editing_tests_collection.insertTranslations({a: 5, b: 2}, {aa: {u: 1, v: 2, w: 3, x: 4, y: 2, z: 1}})
        result = translations_editing_tests_collection.removeLanguage _id, ["x", "y"]
        test.equal result, 1, "Correct number of affected documents"
        result = translations_editing_tests_collection.removeLanguage _id, ["y", "z"], {}
        test.equal result, 1, "Correct number of affected documents"
        result = translations_editing_tests_collection.removeLanguage _id, ["u", "v"], (err, affected_rows) ->
          Meteor.setTimeout (->
            test.equal 1, affected_rows
            test.equal \
              translations_editing_tests_collection.findOne(_id, {transform: null}),
              {a: 5, b: 2, i18n: {aa: {w: 3}}, _id: _id}
            onComplete()
          ), 1000

  Tinytest.addAsync 'tap-i18n-db - translations editing - removeLanguage - complete remove - language_tag=TAPi18n.getLanguage()', (test, onComplete) ->
    TAPi18n.setLanguage("aa")
      .done ->
        _id = translations_editing_tests_collection.insertTranslations({a: 5, b: 2}, {aa: {u: 1, v: 2, w: 3, x: 4, y: 2, z: 1}})
        result = translations_editing_tests_collection.removeLanguage _id, null, (err, affected_rows) ->
          Meteor.setTimeout (->
            test.equal 1, affected_rows
            test.equal \
              translations_editing_tests_collection.findOne(_id, {transform: null}),
              {a: 5, b: 2, i18n: {}, _id: _id}
            onComplete()
          ), 1000

  Tinytest.addAsync 'tap-i18n-db - translations editing - removeLanguage - attempt complete remove base language - language_tag=TAPi18n.getLanguage()', (test, onComplete) ->
    TAPi18n.setLanguage("en")
      .done ->
        _id = translations_editing_tests_collection.insertTranslations({a: 5, b: 2}, {aa: {u: 1, v: 2, w: 3, x: 4, y: 2, z: 1}})
        result = translations_editing_tests_collection.removeLanguage _id, null, (err, affected_rows) ->
          Meteor.setTimeout (->
            test.isFalse affected_rows
            test.instanceOf err, Meteor.Error
            test.equal err.reason, "Complete removal of collection's base language from a document is not permitted"
            onComplete()
          ), 1000
