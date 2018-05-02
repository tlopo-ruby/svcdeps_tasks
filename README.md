# RSpec tests for Service Dependencies

### USAGE 

Add the following to Rakefile: 

```ruby
require 'svcdeps_tasks'

ENV['SVCDEPS_PATH'] = '/etc/svcdeps'
```

And save yaml files  describing how to check the  service dependencies, like: 

```yaml
deps: 
  - type: tcp
    host: www.google.com
    port: 80
    timeout: 2
    desc: Should be able to tcp port ping www.google.com:80
    
  - type: udp
    host: 8.8.8.8
    port: 53
    timeout: 2
    desc: Should be able to udp port ping DNS server(8.8.8.8:53)

  - type: http
    method: get
    url: https://www.google.com:80
    insecure: false
    timeout: 2
    desc: Should be able to hit http://www.google.com:80
    
  - type: command
    run_as: nobody
    command: ping -c 1 8.8.8.8
    timeout: 2 
    desc: Should be able to ping 8.8.8.8
```
