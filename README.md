# RSpec tests for Service Dependencies

### USAGE 

1. Install the gem
```bash 
gem install svcdeps_tasks
```

2. Add the following to Rakefile: 
```ruby
require 'svcdeps_tasks'

ENV['SVCDEPS_PATH'] = '/etc/svcdeps'
```

3. Create a directory for dependencies manifests, `/ec/svcdeps` in our case: 
```bash
mkdir /etc/svcdeps
```

4. Create dependencies manifests, which are yaml files describing how to check the  service dependencies: 

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
    url: https://www.google.com
    insecure: false
    timeout: 2
    desc: Should be able to hit https://www.google.com
    
  - type: command
    command: ping -c 1 8.8.8.8
    timeout: 2 
    desc: Should be able to ping 8.8.8.8
```

5. Run: 

```
# rake spec:svcdeps

Service Dependencies
  Should be able to tcp port ping www.google.com:80
  Should be able to udp port ping DNS server(8.8.8.8:53)
  Should be able to hit https://www.google.com
  Should be able to ping 8.8.8.8

Finished in 0.16224 seconds (files took 0.28904 seconds to load)
4 examples, 0 failures
```
