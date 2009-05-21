Lighthouse Cards
===

This is just a little sinatra app to generate a printable set of index cards from your list of open lighthouse tickets.

This should make it easy to be as agile, scrum, XP, or whatever your process is while still working with lighthouse.

To use create a config.yml file in your app root with the following entries:

<pre>
project_key: 8994-ruby-on-rails
account_name: rails
auth_token: blahblahblah12341234
</pre>

TODO:
---
  * make it smart enough to only print cards that haven't been printed
  * make the search query dynamic
  * stop using safari only selectors so it looks nice
  
---

Copyright 2009 John Barton & Envato
