# Rotom Protos

This repository contains the protobuf definitions for Rotom.

## Connecting to Rotom

## As an MITM

You make two types of websocket connection to rotom.  The first
is to the control channel to identify you as a device; then you
make as many connections as you like to the data channel to establish
workers that are available for connection.

### Control channel

1. Connect to `ws://<address>/control`
1. Send an introduction packet: `{"deviceId":"xx", "version": yy, "origin": "xyz", "publicIp": "10.0.1.1" }`

These commands may be sent to you by rotom; note that commands are
send with an id number, and responses include this id number.

Note that the deviceId needs to correlate with your proto stream connections

#### Run a command

```
> {"id": 6, "method": "runJob", "payload": {"command": "whoami"}}
< {"id":6,"status":200,"body":{"commandResult":"root"}}
```

### Reboot device
```
> {"id": 11, "method": "reboot", "payload": null}
< {"id":11,"status":200}
```

### Restart game/mitm
```
> {"id": 9, "method": "restartApp", "payload": null}
< {"id":9,"status":200}
```

### Get memory usage
```
> {"id": 12, "method": "getMemoryUsage", "payload": null}
< {"id": 12,"status":200,"body":{"memFree":1000000, "memMitm": 500000, "memStart": 400000}}
```

### Get screen size (unused)
```

> {"id": 7, "method": "getScreenSize", "payload": null}
< {"id":7,"status":200,"body":{"width":1080,"height":1920}}
```

### Click screen (unused)

```
> {"id": 8, "method": "clickScreen", "payload": {"posX": 10, "posY": 10}}
< {"id":8,"status":200,"body":{"screenshot":"\/9j\/4AAQSkZJ..."}}
```

### Get logcat (unused)

```
> {"id": 10, "method": "getLogcat", "payload": null}
< {"id":10,"status":200,"body":{"zipData":"<base64>"}}
```

#### Take a screenshot (unused)
```
> {"id": 5, "method": "screenshot", "payload": null}
< {"id":5,"status":200,"body":{"screenshot":"\/9j\/4AAQSkZJ..."}}
```

## Proto connection

Connect to `ws://<address>/`
Send the WelcomeMessage proto; note that the worker id currently
must be of the form devicedId + a unique suffix per worker id.

You may now wait for incoming messages.  The first message that
you received will be a MitmRequest of the form LoginRequest which will contain a `PtcToken`
protobuf. The login request will also indicate whether the client
support compression.  You should now login to the game using this token and respond
with a LoginResponse form of MitmResponse, where you can indicate
whether you support compression.

Subsequently you will receive protos via MitmRequest; and you should expect
to receive these concurrently.  Once responses are received from the game servers
you should respond to these with the id as the correlation key.

If a packet is compressed, this will be indicated; and you can choose
to compress a response if the client has asked.  This is generally
worth doing only for long (eg > 100 byte) responses.

On disconnection, you can assume that the connection is dead and can
perform any cleanup required. There is no attempt to resume connections.

See the discussion about compression above.
