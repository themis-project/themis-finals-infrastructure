# Plan
Carefully rewrite *Koibasta/femida* contest checking system
## Reasons
1. No need to use Websockets because data is transfered from server to clients. It is better to use Server-Sent Events as in [themis-quals](https://github.com/VolgaCTF/themis-quals) contest checking system.
2. Ruby code is ugly. Refactoring should be done.
3. Using Ruby as backend along with Node.js as frontend with Beanstalkd as a transport mechanism is slow and not robust. Node.js is used because it has better support for Websockets, but as it said in p.1 Websockets will be replaced with Server-Sent Events which can be implemented in plain Ruby.
4. Node.js is not suitable for making Telnet server which accepts flags. It will be better to use web endpoint to accept flags (though it's kinda ususual for CTFs).
5. Managing system configuration is sort of complex stuff. There should be used some provisioning systems such as SaltStack or Chef.

## Good things about current system
1. API for interacting between service checkers and contest checking system. It is considered stable.
2. Good choice was made for data storage (PostgreSQL), checkers <=> system interaction (Beanstalkd), realtime events propagation (Redis).

## System components
1. Provisioning system - Vagrant, SaltStack/Chef.
2. Operating system - Ubuntu 14.04 Server.
3. Data storage - PostgreSQL.
4. Internal messaging server - Beanstalkd.
5. Event propagation server - Redis.
6. Backend - Ruby application (Sinatra) running on Thin server.
7. Backend proxy, assets - Nginx.
8. Website - ES6 (Babel), CommonJS (Browserify), Bootstrap & React.js for UI, EventSource for event propagation.
9. Process management - Supervisor/God.