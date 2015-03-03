# tap-i18n-db

Extends the tap:i18n package to allow the translation of collections.

### Internationalization for Meteor Collections

**tap-i18n-db** is a [Meteor](http://www.meteor.com) package that
extends [tap-i18n](https://github.com/TAPevents/tap-i18n) to allow the translation of collections.

Developed by <a href="http://www.meteorspark.com"><img src="http://www.meteorspark.com/logo/logo-github.png" title="MeteorSpark" alt="MeteorSpark"></a> [Professional Meteor Services](http://www.meteorspark.com)<br/> for <a href="http://tapevents.com/"><img src="http://tapevents.com/wp-content/uploads/2015/02/TAPevents_logo_144px.png" title="TAPevents" alt="TAPevents" style='margin-top:10px'>&nbsp; Event Apps Hong Kong</a>.

## Key Features

**Transparent Language-Aware Publications:** You define publish/subscribe methods in the same way you are used to. The fields on the client will be automatically translated and will be updated reactively.

**No Redundancy:** Only the required translations for the current client's language are sent over the wire.

**Easy to Secure & Deliver:** All translations are stored within the original document in single a subdocument. This allows you to easily define access control and simplifies publications.

**Simple Integration:** It's easy to start translating existing collections; no data structure changes are required.

**Intuitive API:** tap-i18n-db's API is designed to be simple and as close as possible to Meteor's native methods, which developers are already familiar with.

**Dialect Fallback:** If a translation is missing, dialects will fallback to their base language (see tap-i18n's [Languages Tags and Translations Prioritization](https://github.com/TAPevents/tap-i18n#languages-tags-and-translations-prioritization)).

## Getting Started

**Step 1:** Install tap-i18n-db:

```bash
$ meteor add tap:i18n-db
```

**Step 2:** Initialize the collection you wish to translate with `new TAPi18n.Collection`

```javascript
Inventors = new TAPi18n.Collection("inventors");
```

**Step 3:** Insert translated documents with `insertTranslations`

```javascript
id = Inventors.insertTranslations({born: 1856, name: "Nikola Tesla"}, {
    zh: {
        name: "尼古拉·特斯拉"
    }
});
```

Any existing documents can be translated with `updateTranslations`

```javascript
Inventors.updateTranslations(id, {
    ru: {
        name: "Ни́кола Те́сла"
    }
})

```

If you are updating from the client, you can use the `translate` method to translate a document to the session's current language. In the following example, we assume that `TAPi18n.getLanguage()` returns `ru` (Russian):

```javascript
Inventors.translate(id, {name: 'Ни́кола Те́сла'});
```

This is equivalent to the above `updateTranslations` example.

**Step 4:** Publish and Subscribe the translated collections

```javascript
if (Meteor.isServer) {
    TAPi18n.publish("inventors", function (born_after) {
        return Inventors.i18nFind({born: {$gt: born_after}});
    });
}

if (Meteor.isClient) {
    TAPi18n.subscribe("inventors", 1800);
}
```

**Step 5:** You can find and fetch documents on the client as normal

```javascript
// client.js
Template.inventors.helpers({
    inventors: function() {
        return Inventors.find();
    }
})

Meteor.startup(function() {
    TAPi18n.setLanguage("ru");
});
```

```html
<!-- client.html -->
<template name="inventors">
    {{#each inventors}}
        <div>{{name}} - {{born}}</div>
    {{/each}}
</template>
```

The above template will automatically render correct translations based on the client's selected language.

**Step 6:** If you already use tap-i18n to internationalize your UI, you are done!

Otherwise, add **project-tap.i18n** file to your project's **root** with the list of
languages tags you want your project to support.

```javascript
// project-root/project-tap.i18n
{
    "supported_languages": ["en", "fr", "ru", "pt-BR"]
}
```

For more details about **project-tap.i18n** please refer to [tap-i18n's README](https://github.com/TAPevents/tap-i18n#configuring-tap-i18n-build-process).


## Caveats


* You must use `i18nFind` for publications. User regular `find` everywhere else.
* `TAPi18n.publish(null, ...)` is not supported. You must name each publication.
* We assume that the fields in your document are in English, if it
isn't the case, use the `base_language` option of the [tap-i18n-db collection constructor](#tap-i18n-db-collections) to set the correct language.
* If you want to use an *inclusive* `fields` option in a **client-side** query, `i18n` must be part of the fields subset. Otherwise, it won't be reactive, e.g. `Inventors.find({}, {fields: {born: 1, i18n: 1}});`.

## Data Structure

### In MongoDB

Each tap-i18n-db collection has a *base language* (English by default). The
document's fields are in the *base language* and the translations for these
fields are kept in a in a subdocument named `i18n`, example:

```javascript
{
    name: "Nikola Tesla",
    born: 1856,
    place_of_birth: {
        country: "Austrian Empire",
        city: "Smiljan"
    },
    i18n: {
        zh: {
            name: "尼古拉·特斯拉",
            place_of_birth: {
                country: "奧地利帝國"
                // Chinese translation does not have city defined, so it will fallback to English
            }
        },
        ru: {
            name: "Ни́кола Те́сла",
            place_of_birth: {
                country: "Австрийская империя",
                city: "Смилян"
            }
        }
    }
}
```

You can maintain the above structure by yourself or use tap-i18n-db's 
[translations editing methods](#collections---translations-editing).

### On the Client

On the client, tap-i18n-db documents won't show the i18n subdocument.
Instead, you'll see the fields overridden by their translation in the current
client's language.

Example: If a client uses the *zh* language, the document from the previous
section will appear on the client as:

```javascript
{
    name: "尼古拉·特斯拉",
    born: 1856,
    place_of_birth: {
        country: "奧地利帝國",
        city: "Smiljan"
    }
}
```

### Data & Security

Since all the translations are in the i18n subdocument, by setting allow/deny
rules that allow or restrict access to this field, you can control who can edit
translations.



## Package Developers

You can use tap-i18n-db to support the translation of your package's
collections. Keep in mind that it is the project developer that manage the
client's language and set the supported languages.

The i18n subdocuments of your collections will be ignored in projects that will
use your package without installing and configuring tap-i18n.

Please refer to the [Developing Packages section of tap-i18n's
REAMDE](https://github.com/TAPevents/tap-i18n/#developing-packages) to get more
background about tap-i18n and package development. You don't need to follow the
"Setup tap-i18n" steps in your package to use tap-i18n-db.

**Notes:**

* All the [translation editing methods](#collections---translations-editing)
  will fail if tap-i18n is not enabled in the project level. The optional
  callback argument will be called with an error object as the first argument (a
  log will be sent to the console if there is no callback).

## API

### Relevant tap-i18n Methods

**TAPi18n.setLanguage(language\_tag)** *Client*

Documentation available on [TAPi18n's README](https://github.com/TAPevents/tap-i18n#tapi18n-api).

**Note:** The returned deferred object resolves or fails when the language
file load succeed or fail. The actual load of the collections translations
begins upon resolution of the deferred (upon successful language change).

### tap-i18n-db Collections

**TAPi18n.Collection(name, options)** *Anywhere*

Constructor for tap-i18n-db collections.

It extends Meteor.Collection with the TAPi18n.Collection API.

**Additional options:**

On top of the options [supported by Meteor.Collection](http://docs.meteor.com/#collections), TAPi18n.Collection also
has:

*base_language*: We assume that the fields in your document are in English, if
it isn't the case, use the *base_language* option to set the correct language
tag.

Check [Meteor.Collection documentation](http://docs.meteor.com/#collections)
for arguments documentation.

### Publish and Subscribe

**TAPi18n.publish(name, func)** *Server*

Publish a language aware record set.

Use just like you use [Meteor.publish()](http://docs.meteor.com/#meteor_publish),
but instead of using Collection.find() to generate a cursor use
`tap_i18n_collection.i18nFind()`.

Inside *func* you can get the client's language tag with `this.language`. It
will be null if language is not defined.

Just like it works in `Meteor.publish()` the publish function can return cursors,
or control its published record set directly.

Note: `TAPi18n.publish(null, ...)` is not supported.

**tap_i18n_collection.i18nFind(selector, [options])** *Server*

Generates a language aware cursor for the publish methods of TAPi18n.publish.

This method will work only when it's called from a publish methods of
TAPi18n.publish().

Use just like you use [collection.find()](http://docs.meteor.com/#find).

**TAPi18n.subscribe(name [, arg1, arg2, ... ] [, callbacks])** *Client*

Subscribe to a tap-i18n-db publication.

Use just like you use [Meteor.subscribe()](http://docs.meteor.com/#meteor_subscribe).

### Collections - Translations Editing

**tap_i18n_collection.insertTranslations(doc, translations, [callback])** *Anywhere*

Insert a document and its translations into the collection. Returns its unique _id.

The *doc* and *callback* arguments are just like [collection.insert()](http://docs.meteor.com/#insert).

*translations* object should be like:

```javascript
{
  'language-tag': {
      'field_a': "field_a translation to language-tag",
      'field_b': "field_a translation to language-tag",
      .
      .
      .
  },
  'language-tag': {...}, ...
}
```

**Notes:**

* If one of the translations languages-tag is the collection's base language
  we'll override the doc fields with the fields that it contains.
* If language-tag is an unsupported language tag the optional callback argument
  will be called with an error object as the first argument (a log will be sent
  to the console if there is no callback).

Example:

```javascript
tap_i18n_col.insertTranslations({a: 1, b: 5}, {aa: {c: 3}, en: {b: 2, d: 4}});
// -> will insert: {a: 1, b: 2, d: 4, i18n: {aa: {c: 3}}, _id: _id}
```

**tap_i18n_collection.updateTranslations(selector, translations, [options], [callback])** *Anywhere*

Merge *translations* with the existing translations of the selected
documents. Returns the number of affected documents.

The *translations* argument should be like the one of *tap_i18n_collection.insertTranslations()*

The *selector*, *options* and *callback* arguments are just like [collection.update()](http://docs.meteor.com/#update)

Example:

```javascript
_id = tap_i18n_col.insertTranslations({a: 5, b: 2}, {aa: {x: 4, y: 2}, "aa-AA": {l: 1}})
tap_i18n_col.updateTranslations(_id, {en: {a: 1}, aa: {x: 1}})
// resulted document -> {a: 1, b: 2, i18n: {aa: {x: 1, y: 2}, "aa-AA": {l: 1}}, _id: _id}
```

**tap_i18n_collection.removeTranslations(selector, fields, [options], [callback])** *Anywhere*

Remove translations from the selected documents. Returns the number of affected
documents.

*fields* is an object of the form:

```javascript
["lang-tag1.field_name_a", "lang-tag1.field_name_c", "lang-tag2"]
```

If you specify a language without a field (like "lang-tag2" in the above
example), if that language is not the collection's base language, all the
translations to that language will be removed.

We don't allow the complete removal of the base language translations, since
tap-i18n-db doesn't distinguish between "translated" fields and other fields
the document has, so removal of the base language would mean the removal of the
document. If fields will contain a request to remove the Collection's base
language we won't remove any field and the optional callback argument will be
called with an error object as the first argument (a log will be sent to the
console if there is no callback).

The underlying method used for removeTranslations is `collection.update` with
the *$unset* operator, the *selector*, *options* and *callback* arguments are
just like [collection.update()](http://docs.meteor.com/#update)

Example:

```javascript
_id = tap_i18n_col.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2}, "aa-AA": {l: 1, m: 2}})
tap_i18n_col.removeTranslations(_id, ["en.a", "aa.y", "aa-AA"]);
// -> result: {b: 2, i18n: {aa: {x: 1}}, _id: _id}
```

**tap_i18n_collection.insertLanguage(doc, language_translations, [language_tag=TAPi18n.getLanguage()], [callback])** *Client*  
**tap_i18n_collection.insertLanguage(doc, language_translations, language_tag, [callback])** *Server*

Insert a document into the collection with translations to the specified
language_tag. Returns its unique _id.

*language_translations* is an object of the form:

```javascript
{
  'field_a': "field_a translation to language-tag",
  'field_b': "field_a translation to language-tag",
  .
  .
  .
}
```

*language_tag* is by default the current client's language or one of the
supported languages tags, if no language is set (TAPi18n.getLanguage() returns
null) you must set the language_tag yourself. On the server you must specify
*language_tag*.

If *language_tag* is null, undefined, or an unsupported language tag the optional
callback argument will be called with an error object as the first argument (a
log will be sent to the console if there is no callback).

**Notes:**

* If *language_tag* is the collection's base language we'll override the doc
  fields with the fields that it contains.

Example:

```javascript
// Assuming tap_i18n_col base language is "en"
tap_i18n_col.insertLanguage({a: 1, b: 5}, {b: 2, d: 4}, "en");
// -> will insert: {a: 1, b: 2, d: 4, _id: _id}

tap_i18n_col.insertLanguage({a: 1, b: 5}, {b: 2, d: 4}, "ru");
// -> will insert: {a: 1, b: 2, d: 4, _id: _id}

// only client side
TAPi18n.setLanguage("zh")
  .done(function () {
    tap_i18n_col.insertLanguage({a: 1, b: 5}, {b: 2, d: 4});
    // -> will insert: {a: 1, b: 5, i18n: {zh: {b: 2, d: 4}}, _id: _id}
  });
```

**tap_i18n_collection.updateLanguage(selector, language_translations, [language_tag=TAPi18n.getLanguage()], [options], [callback])** *Client*   
**tap_i18n_collection.updateLanguage(selector, language_translations, language_tag, [options], [callback])** *Server*

*Alias: tap_i18n.translate*

Merge *language_translations* with the existing translations of language_tag in
the selected documents. Returns the number of affected documents.

The *language_translations* and *language_tag* arguments should be like in
*tap_i18n_collection.insertLanguage()*.

The *selector*, *options* and *callback* arguments are just like in
[collection.update()](http://docs.meteor.com/#update).

Example:

```javascript
TAPi18n.setLanguage("aa")
  .done(function () {
    _id = tap_i18n_col.insertTranslations({a: 1, b: 2}, {aa: {x: 9, y: 2, z: 1}})
    tap_i18n_col.updateLanguage(_id, {x: 1, z: 3});
    // -> result: {a: 1, b: 2, i18n: {aa: {x: 1, y: 2, z: 3}}, _id: _id}
  });
```

**tap_i18n_collection.removeLanguage(selector, fields, [language_tag=TAPi18n.getLanguage()], [options], [callback])** *Client*  
**tap_i18n_collection.removeLanguage(selector, fields, language_tag, [options], [callback])** *Server*

Remove *language_tag*'s translations from the selected documents. Returns the
number of affected documents.

The *language_tag* argument should be like in
*tap_i18n_collection.insertLanguage()*.

*fields* should be an array of fields which their translations to
*language_tag* you want to remove, example:

```javascript
["field_a", "field_b", ...]
```

If *fields* is null and *language_tag* is not the collection's base language,
all the translations to *language_tag* in the selected documents will be
removed. If *language_tag* is the collection's base language 

If *fields* is null and *language_tag* is the collection's base language, the
optional callback argument will be called with an error object as the first
argument (a log will be sent to the console if there is no callback).

The underlying method used for *removeLanguage* is `collection.update` with the
*$unset* operator. The *selector*, *options* and *callback* arguments are just
like [collection.update()](http://docs.meteor.com/#update)

Example:

```javascript
TAPi18n.setLanguage("aa")
  .done(function () {
    // remove some translations of language aa
    _id = tap_i18n_col.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2, z: 3}})
    tap_i18n_col.removeLanguage(_id, ["x", "z"]);
    // -> result: {a: 1, b: 2, i18n: {aa: {y: 2}}, _id: _id}

    // remove all the translations of language aa
    _id = tap_i18n_col.insertTranslations({a: 1, b: 2}, {aa: {x: 1, y: 2, z: 3}, "aa-AA": {l: 1}})
    tap_i18n_col.removeLanguage(_id, null);
    // -> result: {a: 1, b: 2, i18n: {"aa-AA": {l: 1}}, _id: _id}
  });
```

## Unit Testing

We have more than one unittests to test the different ways tap-i18n-db might be used in a
certain project, to test all of them run:

    $ ./unittest/unittest-all

The unittest will be available on: [http://localhost:3000](http://localhost:3000) .

We call the different ways tap-i18n-db might be used *environments*. Each time
you'll break the run of the above command (by pressing ctrl+c) the test for
another environment will run, refresh your browser to load the test for the new
environment.

You can also test a specific environment:

    # tap-i18n is disabled in the project level
    $ ./unittest/unittest-disabled 

    # tap-i18n enabled in the project level - default project-tap.i18n
    $ ./unittest/unittest-enabled

    # tap-i18n enabled in the project level the autopublish package is installed - default project-tap.i18n
    $ ./unittest/unittest-enabled_autopublish

## Author

[Daniel Chcouri](http://theosp.github.io/)

## Contributors

[Chris Hitchcott](https://github.com/hitchcott/)
[Rijk van Wel](https://github.com/rijk)

## Credits

* [tap-i18n](https://github.com/TAPevents/tap-i18n)

Sponsored by [TAPevents](http://tapevents.com)


