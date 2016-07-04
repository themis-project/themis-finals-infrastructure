# Themis Finals Infrastructure
[![Latest Version](https://img.shields.io/github/release/aspyatkin/themis-finals-infrastructure.svg?style=flat-square)](https://github.com/aspyatkin/themis-finals-infrastructure/releases)
[![License](https://img.shields.io/github/license/aspyatkin/themis-finals-infrastructure.svg?style=flat-square)](https://github.com/aspyatkin/themis-finals-infrastructure/blob/master/LICENSE)
[![Dependencies status](https://img.shields.io/gemnasium/aspyatkin/themis-finals-infrastructure.svg?style=flat-square)](https://gemnasium.com/aspyatkin/themis-finals-infrastructure)  

Vagrant development environment and Chef server configuration for Themis Finals. Part of [Themis Finals](https://github.com/aspyatkin/themis-finals) project.

## Prerequisites
1. [VirtualBox](https://virtualbox.org) 5.0.14 or later;
2. [Vagrant](https://www.vagrantup.com/) 1.8.1 or later;
3. *nix shell (use Cygwin x64 on Windows);
4. Git 2.x;
5. Ruby 2.2.x;
6. [vagrant-helpers](https://github.com/aspyatkin/vagrant-helpers) plugin;
7. [Bundler](http://bundler.io/).

**Windows specific** See [this gist](https://gist.github.com/aspyatkin/2a1305cceb9101caa2f6) to find out how to install Ruby 2.2.4 on Cygwin x64.

## Get the code
```sh
$ cd ~/Documents/projects
$ git clone -b develop https://github.com/aspyatkin/themis-finals-infrastructure
```

## Configuring
### Create data bag encryption key

```sh
$ cd ~/Documents/projects/themis-finals-infrastructure/
$ openssl rand -base64 512 | tr -d '\r\n' > encryption_keys/development_key
```

### For developers
For development purposes, several encrypted data bags should be placed into your Chef repository - *ssh* and *git*. If you don't have push access to Themis Finals project repositories, you don't need to configure them and you can proceed to *System config* section right away.

#### *ssh* data bag
Contains your private OpenSSH GitHub key. To create a data bag, run

```sh
$ cd ~/Documents/projects/themis-finals-infrastructure
$ knife solo data bag create ssh development
```

Below is the sample:

```json
{
  "id": "development",
  "keys": {
    "id_ed25519": "-----BEGIN OPENSSH PRIVATE KEY-----\n.......................\n-----END OPENSSH PRIVATE KEY-----\n"
  }
}
```

#### *git* data bag
Contains your git configuration, such as `user.email` and `user.name` settings. To create a data bag, run

```sh
$ cd ~/Document/projects/themis-finals-infrastructure
$ knife solo data bag create git development
```

Below is the sample:

```json
{
  "id": "development",
  "config": {
    "user.name": "Alexander Pyatkin",
    "user.email": "aspyatkin@users.noreply.github.com"
  }
}
```

### System config
Most options are stored in `themis-finals` cookbook's attributes or environment file. However, sensitive ones (passwords, API keys and so on) are stored in encrypted data bags.

#### *postgres* data bag
Contains PostgreSQL account passwords. To create a data bag, run

```sh
$ cd ~/Documents/projects/themis-finals-infrastructure
$ knife solo data bag create postgres development
```

Below is the sample:

```json
{
  "id": "development",
  "credentials": {
    "postgres": "sometrickypassword",
    "themis_finals_user": "sometrickypassword"
  }
}
```

## Setup
The following actions should be executed in a directory with `themis-finals-infrastructure` repository.

1. Create `opts.yaml` file based on the example provided in `opts.example.yaml` (note there is configuration for 3 VMs, in this step you only need to configure `master` VM);
2. Run `bundle` to install necessary Ruby gems;
3. Run `bundle exec berks install` to install Chef cookbooks;
4. Map `finals.volgactf.dev` in your system's hosts file to an IP address specified in `opts.yaml` file;
5. Launch virtual machine with `vagrant up master`;
6. Install Chef on target machine with `bundle exec knife solo prepare finals.volgactf.dev`;
7. Provision virtual machine with `bundle exec knife solo cook finals.volgactf.dev`.

**Windows specific** See [this gist](https://gist.github.com/aspyatkin/2a70736080835ac594ba) to discover how to install [Berkshelf](https://github.com/berkshelf/berkshelf) on Cygwin x64.

**Windows specific 2** Note the last command - you will need to pass an additional parameter `--ssh-control-master=no`

## Contest
Contest configuration and management are done on the guest virtual machine (`master`). In order to get access to this machine, you should run the following commands:

```sh
$ cd ~/Documents/projects/whatever/themis-finals-infrastructure
$ vagrant ssh master
```

### Configuration file
Create configuration file

```sh
$ cd /var/themis/finals/backend
$ cp config.rb.example config.rb
```
All system settings are stored in `config.rb` file, including network, team and service options.

#### Network options
Internal network is a network from which contest organisers manage the competition state. In this particular case,

``` ruby
network do
    internal '172.20.0.0/24'
    # other settings
end
```

#### Team options

Each team is described in its own section. There should be specified a team alias (for internal use), team name, network and game machine (the one with vulnerable services) address. For instance,

``` ruby
team 'team_1' do
    name 'Team #1'
    network '172.20.1.0/24'
    host '172.20.1.2'
end
```

#### Service options

Each service is described in its own section. There should be specified a service alias (for internal use) along with service name. For instance,

``` ruby
service 'service_1' do
    name 'Service #1'
end
```

### Service checker
Service checker should be placed into a separate subfolder in `/var/themis/finals/checkers` folder. You can check out the examples in `/var/themis/finals/checkers/sample-checker-rb` and `/var/themis/finals/checkers/sample-checker-py`.

Service checker is launched by [Supervisor](http://supervisord.org), so you should create a configuration file in `/etc/supervisor.d` (check out samples `themis.finals.service.service_1.checker.conf` and `themis.finals.service.service_2.checker.conf` in that directory). You should specify program's run command, working directory, log file paths and several internal options:  
1. `TUBE_LISTEN` - `themis.finals.service.SERVICE_ALIAS.listen`,  
2. `TUBE_REPORT` - `themis.finals.service.SERVICE_ALIAS.report`,  
where `SERVICE_ALIAS` stands for service alias which you've specified in `config.rb` file.

Instead of deploying this stuff manually, you can write a Chef cookbook to automate deployment (this is done for sample checkers).

### Management
There are some command line tools to manage the contest.

#### Reset
Use before starting new contest. These commands re-create a system's database.

```sh
$ cd /var/themis/finals/backend
$ bundle exec rake db:reset
$ bundle exec rake contest:init
```

#### Start processes

```sh
$ sudo supervisorctl
> start all
> exit
$
```

#### Schedule start contest

```sh
$ cd /var/themis/finals/backend
$ bundle exec rake contest:start_async
```

Contest will be started automatically after the first flags will have become created.
Assuming `master` virtual machine has an IP address `172.20.0.2`, you can navigate to `http://172.20.0.2/` in your browser to see system's frontend.

#### Pause contest

```sh
$ cd /var/themis/finals/backend
$ bundle exec rake contest:pause
```

#### Resume contest

```sh
$ cd /var/themis/finals/backend
$ bundle exec rake contest:resume
```

#### Schedule complete contest

```sh
$ cd /var/themis/finals/backend
$ bundle exec rake contest:complete_async
```

Contest will be stopped automatically after all flags will have become expired and all scores will have become recalculated.

#### Stop processes

```sh
$ sudo supervisorctl
> stop all
> exit
$
```

To start new contest, you should stop running processes and reset.

#### Restart your checker's process
Sometimes things get messed up and you end up rewriting your service's checker during a running contest. Here is a way to restart checker's process.

```sh
$ sudo supervisorctl
> status
> restart themis.finals.service.SERVICE_ALIAS:*
> exit
$
```

### Disabling scoreboard (for team and guest networks)

```sh
$ cd /var/themis/finals/backend
$ bundle exec rake scoreboard:disable
```

### Attacking
You can attack only from team networks. To accomplish this, you should run another virtual machine with an appropriate IP address. Example `opts.example.yaml` file contains configuration for extra VM instances - `team1` and `team2` (Ubuntu Desktop). Inside a team's machine, you can use several options to perform an attack. Please refer to [themis-attack-protocol](https://github.com/aspyatkin/themis-attack-protocol) and [themis-attack-py](https://github.com/aspyatkin/themis-attack-py) to discover them.

You can manage team virtual machines with Chef as well. Each machine should be resolved as `teamN.finals.volgactf.dev` where `N` stands for the team number. For instance, `team1.finals.volgactf.dev` is a domain name for team #1. Assuming your network is `172.20.0.0/16`, team #1 virtual machine will have an IP address `172.20.1.2`. The next instructions are pretty similar to the process of configuring `master` instance:
1. Map `team1.finals.volgactf.dev` in your system's hosts file to an IP address specified for team #1 in `opts.yaml` file;
2. Launch virtual machine with `vagrant up team1`;
3. Install Chef on target machine with `bundle exec knife solo prepare team1.finals.volgactf.dev`;
4. Provision virtual machine with `bundle exec knife solo cook team1.finals.volgactf.dev`;
5. Repeat steps 1-4 for the other team virtual machines specified in `opts.yaml` file.

Inside a team's virtual machine, you can use a pre-installed (if instance is managed with Chef) utility [themis-attack](https://github.com/aspyatkin/themis-attack-py) to send flags to the checking system.

### Tips
#### Getting hold of issued flags
To find out some flags to test attacks, open `/var/themis/finals/logs/queue.log`.
#### Supervisor web interface
You can use web interface to start processes, view log tails etc. It's available on port 9001 of the master instance (e.g. `http://172.20.0.2:9001` in your web browser's address bar).

## See also
- [themis-finals-backend](https://github.com/aspyatkin/themis-finals-backend)
- [themis-finals-frontend](https://github.com/aspyatkin/themis-finals-frontend)
- [themis-finals-stream](https://github.com/aspyatkin/themis-finals-stream)
- [themis-attack-protocol](https://github.com/aspyatkin/themis-attack-protocol)
- [themis-attack-py](https://github.com/aspyatkin/themis-attack-py)
- [themis-attack-result](https://github.com/aspyatkin/themis-attack-result)
- [themis-checker-server](https://github.com/aspyatkin/themis-checker-server)
- [themis-checker-result](https://github.com/aspyatkin/themis-checker-result)
- [themis-checker-py](https://github.com/aspyatkin/themis-checker-py)

## License
MIT @ [Alexander Pyatkin](https://github.com/aspyatkin)
