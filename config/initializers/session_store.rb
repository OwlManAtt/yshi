# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_yshi_session',
  :secret      => 'a274bad4aeec4cc326716db2aef280e64a9f11e9470b6b657aa1394c83b33a88cb2de71b0104f8c6173befa6eda00abec5efa85927e57dd3204745313732e15d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
