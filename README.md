# Rest in Peace AIM

## Introduction

AOL Instant Messenger has had a great run...

![AIM Getting Older](images/aim-getting-older.png)

but it just kept getting older. Sad!

It will be no more [in December 2017](http://mashable.com/2017/10/06/aim-discontinued-december-2017/).

![AIM Getting Older](images/rip.jpeg)

This project is a sample messenging rails 5 API built with docker-compose to commemorate the passing of AIM.

## Setup

### Pre-requisites

You will need to install:

1. docker-machine
2. docker
3. docker-compose

Here are the versions used to build this project for reference.

```bash
$ docker-machine -v && docker -v && docker-compose -v
docker-machine version 0.13.0, build 9ba6da9
Docker version 17.10.0-ce, build f4ffd25
docker-compose version 1.17.0, build ac53b73
```

### Bootstraping app

There are a few steps to running the app:

- Run docker-compose in detached mode
- Source the alias file (creates convenience commands `docker_rails && docker_compose`)
- Run `docker_rails db:reset` to setup and seed the database

```bash
$ cd <app_root>
$ docker-compose up -d
$ source ./build/alias.sh # creates docker_rails && docker_rspec aliases
$ docker_rails db:reset # bootstraps database
```

## Making Requests

The main goal of the app is to create users and allow users to send messages to each other.

Only logged-in users can send messages. Here are example requests to get you started.

**NOTE: These commands only work after [bootstrapping the app](#bootstraping-app)**

Make sure that the docker images are running via `docker-compose up -d` before attempting to run these commands.

### Creating a user

```bash
# create user, this will also sign you in
$ curl -H 'Content-Type: application/json' -c ~/cookie.txt \
  $(docker-machine ip):3000/v1/users \
  -d '{"username":"running_aim_icon", "password":"hello123"}' | \
  python -m 'json.tool'

# output

{
    "created_at": "2017-11-05T02:24:24.781Z",
    "id": "42e808d5-6ba6-4eb8-97be-d1c904ffb99d",
    "updated_at": "2017-11-05T02:24:24.781Z",
    "username": "running_aim_icon"
}
```

### Log-in to an existing account

```bash
# or login to an existing account
$ curl -H 'Content-Type: application/json' -c ~/cookie.txt \
  $(docker-machine ip):3000/v1/sessions/login \
  -d '{"username":"myusername1", "password":"passw0rd"}' | \
  python -m 'json.tool'

# output

{
    "created_at": "2017-11-05T02:23:26.001Z",
    "id": "6928bee2-47a5-47a9-9e14-3d29b68e1c58",
    "updated_at": "2017-11-05T02:23:26.001Z",
    "username": "myusername1"
}
```

### Find other users

This is a convenience endpoint to find users to send messages to.

Since all the seed data has usernames starting with 'myuser', this example uses that for the `search_prefix`.

In a real app, you might use something like ElasticSearch with full-text search for something like this, but for this app, all you get a prefix option with an index on the username in Postgres. It's good enough ;).

```bash
# limit and page are optional
$ curl -H 'Content-Type: application/json' -b ~/cookie.txt \
  "$(docker-machine ip):3000/v1/users?search_prefix=myuser&limit=2&page=2" | \
  python -m 'json.tool'

# output

{
    "data": [
        {
            "id": "e9a6b696-6fd7-4bff-908c-ed9c65e88f3b",
            "username": "myusername5"
        },
        {
            "id": "9bd21186-c0f2-4add-917c-b0b4ff36ca70",
            "username": "myusername6"
        }
    ],
    "limit": 2,
    "page": 2,
    "total": 10
}
```

### Creating a message

Now that you have the logged user ID from either POST sessions/login or POST users,
try sending a message

```
your user: 42e808d5-6ba6-4eb8-97be-d1c904ffb99d
myusername6 user: 9bd21186-c0f2-4add-917c-b0b4ff36ca70
```

```base
$ curl -H 'Content-Type: application/json' -b ~/cookie.txt \
  "$(docker-machine ip):3000/v1/42e808d5-6ba6-4eb8-97be-d1c904ffb99d/messages" \
  -d '{ "recipient_id": "9bd21186-c0f2-4add-917c-b0b4ff36ca70", "content": "hi-oh", "message_type": "text", "metadata": "{\"tags\":\"That sunset tho!\"}" }' | \
  python -m json.tool

# output
{
    "content": "hi-oh",
    "created_at": "2017-11-05T02:36:15.362Z",
    "message_type": "text",
    "metadata": "{\"tags\":\"That sunset tho!\"}",
    "modified_at": "2017-11-05T02:36:15.362Z",
    "recipient_id": "9bd21186-c0f2-4add-917c-b0b4ff36ca70",
    "sender_id": "42e808d5-6ba6-4eb8-97be-d1c904ffb99d"
}
```

### Retrieve your message

```bash
 # limit and page are optional
$ curl -H 'Content-Type: application/json' -b ~/cookie.txt \
  "$(docker-machine ip):3000/v1/42e808d5-6ba6-4eb8-97be-d1c904ffb99d/messages?recipient_id=9bd21186-c0f2-4add-917c-b0b4ff36ca70&limit=1&page=0" | \
  python -m json.tool

# output
{
    "data": [
        {
            "content": "hi-oh",
            "created_at": "2017-11-05T02:36:15.362Z",
            "message_type": "text",
            "metadata": "{\"tags\":\"That sunset tho!\"}",
            "modified_at": "2017-11-05T02:36:15.362Z",
            "recipient_id": "9bd21186-c0f2-4add-917c-b0b4ff36ca70",
            "sender_id": "42e808d5-6ba6-4eb8-97be-d1c904ffb99d"
        }
    ],
    "limit": 1,
    "page": 0,
    "total": 1
}
```