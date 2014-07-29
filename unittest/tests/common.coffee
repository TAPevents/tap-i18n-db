test_collections = share.test_collections =
  a: new TAPi18n.Collection "a" # ids in a collection will only be those that % 3 = 0
  b: new TAPi18n.Collection "b" # ids in a collection will only be those that % 3 = 1
  c: new TAPi18n.Collection "c" # ids in a collection will only be those that % 3 = 2

  a_aa: new TAPi18n.Collection "a_aa", {base_language: "aa"}
  b_aa: new TAPi18n.Collection "b_aa", {base_language: "aa"}
  c_aa: new TAPi18n.Collection "c_aa", {base_language: "aa"}

test_collections["a_aa-AA"] = new TAPi18n.Collection "a_aa-AA", {base_language: "aa-AA"}
test_collections["b_aa-AA"] = new TAPi18n.Collection "b_aa-AA", {base_language: "aa-AA"}
test_collections["c_aa-AA"] = new TAPi18n.Collection "c_aa-AA", {base_language: "aa-AA"}

translations_editing_tests_collection = new TAPi18n.Collection "trans_editing"

translations_editing_tests_collection.allow
  insert: -> true
  update: -> true
  remove: -> true

if Meteor.isServer
  Meteor.publish "trans_editing", -> translations_editing_tests_collection.find({})
else
  Meteor.subscribe "trans_editing"

share.translations_editing_tests_collection = translations_editing_tests_collection

for col of test_collections
  test_collections[col].allow
    insert: -> true
    update: -> true
    remove: -> true


collection_classes_map = {
  a: 0,
  b: 1,
  c: 2
}

languages = share.supported_languages = ["en", "aa", "aa-AA"]
max_document_id = share.max_document_id = 30

if Meteor.isClient
  window.test_collections = test_collections
  window.translations_editing_tests_collection = translations_editing_tests_collection

init_collections = () ->
  # clear all test collections
  for collection of test_collections
    test_collections[collection].remove({})

  properties_to_translate = ["not_translated_to_en", "not_translated_to_aa", "not_translated_to_aa-AA"]
  for i in [0...max_document_id]
    for collection_name of test_collections
      collection = test_collections[collection_name]
      base_language = collection_name.replace(/(.*_|.*)/, "") || "en"
      collection_class = collection_name.replace(/_.*/, "")

      if i % 3 != collection_classes_map[collection_class]
        continue

      doc = {_id: "#{share.lpad i, 4}", id: i, i18n: {}}

      # init languages subdocuments
      for language_tag in languages
        if language_tag != base_language
          doc.i18n[language_tag] = {}

      for language_tag in languages
        for property in properties_to_translate
          not_translated_to = property.replace "not_translated_to_", ""
          value = "#{property}-#{language_tag}-#{i}"
          if language_tag != not_translated_to
            if language_tag == base_language
              set_on = doc
            else
              set_on = doc.i18n[language_tag]

            set_on[property] = value

      collection.insert doc

# Server inits
if Meteor.isServer
  # init collections
  init_collections()

  for _class in ["a", "b", "c"]
    do (_class) ->
      TAPi18n.publish "class_#{_class}", (fields=null) ->
        # connect to the 3 types of class
        cursors = []

        if not fields?
          cursors = cursors.concat test_collections["#{_class}"].i18nFind()
          cursors = cursors.concat test_collections["#{_class}_aa"].i18nFind()
          cursors = cursors.concat test_collections["#{_class}_aa-AA"].i18nFind()
        else
          cursors = cursors.concat test_collections["#{_class}"].i18nFind({}, {fields: fields})
          cursors = cursors.concat test_collections["#{_class}_aa"].i18nFind({}, {fields: fields})
          cursors = cursors.concat test_collections["#{_class}_aa-AA"].i18nFind({}, {fields: fields})

        return cursors
