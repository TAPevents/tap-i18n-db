Package.describe({
  name: 'phowat:i18n-db',
  summary: 'Internationalization for Meteor Collections. Forked from tap:i18n-db',
  version: '0.4.1',
  git: 'https://github.com/phowat/tap-i18n-db'
});

Package.on_use(function (api) {
  api.versionsFrom('METEOR@0.9.1');

  api.use(["coffeescript", "underscore", "meteor", "jquery", "reactive-dict"], ['server', 'client']);

  api.use("autopublish", ['server', 'client'], {weak: true})

  api.use('tap:i18n@1.0.3', ['client', 'server']);
  api.imply('tap:i18n', ['client', 'server']);

  api.use('yogiben:admin@1.1.0', {weak: true});

  api.add_files('globals.js', ['client', 'server']);
  api.add_files('tap_i18n_db-common.coffee', ['client', 'server']);
  api.add_files('tap_i18n_db-server.coffee', 'server');
  api.add_files('tap_i18n_db-client.coffee', 'client');
});
