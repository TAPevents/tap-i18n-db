Package.describe({
  summary: 'Internationalization for Meteor Collections',
  version: '0.2.0'
});

Package.on_use(function (api) {
  api.use(["coffeescript", "underscore", "meteor", "jquery", "reactive-dict"], ['server', 'client']);

  api.use("autopublish", ['server', 'client'], {weak: true})

  api.use('tap-i18n', ['client', 'server']);
  api.imply('tap-i18n', ['client', 'server']);

  api.add_files('globals.js', ['client', 'server']);
  api.add_files('tap_i18n_db-common.coffee', ['client', 'server']);
  api.add_files('tap_i18n_db-server.coffee', 'server');
  api.add_files('tap_i18n_db-client.coffee', 'client');
});
