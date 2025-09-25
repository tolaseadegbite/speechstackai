# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# UPDATED: Using the computed hash from your console error for @github/webauthn-json
pin "@github/webauthn-json", to: "@github--webauthn-json.js", integrity: "sha384-lKZgpJHU3pP+iVOsdp+SyHOB2Hlb8cXiyqZZpQRDXkkK2CKtkNO8ZQeSnUZE1KUp" # @2.1.1

# UPDATED: Using the computed hash from your console error for @rails/request.js
pin "@rails/request.js", to: "@rails--request.js.js", integrity: "sha384-z2lUPjZO6VEVMOJPxOpuSNtmIiFZ3ve951XEs/LRW8w/2PqkFoYIatsvFnW1xCA5" # @0.0.12


# UPDATED: Using the computed hash from your console error for lodash
pin "lodash", to: "lodash.js", integrity: "sha384-NA8+CPLa8r4Y5V0ftYvX3rsTtKlJAhsuLcvhvsFvR+mRnliJruCdR57JoiYnKg44" # @4.17.21