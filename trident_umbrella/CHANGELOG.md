# Trident Changelog

## v0.1.0 (11-Oct-2017)

* Initial Umbrella app with basic functionality

### Gateway app

* Based on Plug:Plug.Builder
* http proxy with HTTPoison and no streaming
* config with proxy info and policies
* SSO logic implemented as plugs
* handles login page
* checks policies to determine if route is allowed without authentication
* authenticates session
* Plugs have tests
* Adds user info in cookies for target apps.

### Auth app

* creates data store of session tokens map to user in agent
* creates token for new session

### Directory app

* create data store of user email mapped to user in agent.
* creates users
* config has demo users added through seeds on startup
* demo users are Moe, Curly and Larry. :-)

