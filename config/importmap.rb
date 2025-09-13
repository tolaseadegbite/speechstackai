# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@github/webauthn-json", to: "@github--webauthn-json.js", integrity: "sha384-3RlJBv6B+f8Q76uHoz+/4PwLkXSItOxnFKsPOC3KaH1qGpEwWIBUe0nEwIy7wo6U" # @2.1.1
pin "@rails/request.js", to: "@rails--request.js.js", integrity: "sha384-SpoXbEzc5c/KKHeWA4vN/XkGjtNeZTGsVHnl1eAa/sO3mejyyvsJIDTV+zDo4fcn" # @0.0.12

pin "wavesurfer", to: "https://cdn.jsdelivr.net/npm/wavesurfer.js@7.10.1/dist/wavesurfer.esm.js"
# pin "wavesurfer-regions", to: "https://cdn.jsdelivr.net/npm/wavesurfer.js@7.10.1/dist/plugins/regions.esm.js"