# Setting
1. Copy `.env.sample` to `.env`.

```
$ cp .env.sample .env
```

2. Write environment variable on `.env`
```
SLACK_BOT_TOKEN=xoxp-XXXXXXXXXXX-XXXXXXXXXXXX-XXXXXXXXXXXXX-XXXXXXXXXXXXXX
SLACK_BOT_USERNAME=botuser
SLACK_CHANNEL=#general
SLACK_CHANNEL_OPS=#bot-test
KEYWORD=hoge
```

# Usage
```
$ docker-compose up -d
```
