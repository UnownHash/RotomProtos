# Rotom Protos - `rotom.proto` Explanation/History

This document will go over the `rotom.proto` file. It will be a more in-depth explanation that should solve some oftenly misinterpreted things.

The document will contain both a changelog and a full guide explanation of the protos on a per-block basis.

## Changelog/Update Log

- [30-10-2023 - bb03987:](https://github.com/UnownHash/RotomProtos/commit/bb0398733bcd1571d34ea809a7daf142e9bd9dd3) Initial `rotom.proto` file creation.

- [16-11-2023 - 90eb80d:](https://github.com/UnownHash/RotomProtos/commit/90eb80dfe89b6af718b2b0816242e961c294f470) Add `ptc_oauth` as a method of authentication, to counter PTCs new anti-botting implementations.

- [16-11-2023 - 816030b:](https://github.com/UnownHash/RotomProtos/commit/816030b71dae538ebce06cf7d30a12880bf2af9a) Add a new `RPC_STATUS_MITM_DISALLOWED_REQUEST` RPC status in a attempt to cope with the new anti-botting implementation(s).

- [19-11-2023 - f8bb08a:](https://github.com/UnownHash/RotomProtos/commit/f8bb08a5a2dbd83d75ec33f8a3ab05d3ae133214) Change `MitmResponse.LoginResponse.device_id` to `MitmResponse.LoginResponse.worker_id`, to align with a new controller update.

- [20-2-2024 - 8342c0d:](https://github.com/UnownHash/RotomProtos/commit/8342c0dd1a307ed676da8d132a87eecc22b5f235) Change `MitmResponse.Status` to allow for more abstract custom MITM error messages.

- [06-04-2024 - d75499f:](https://github.com/UnownHash/RotomProtos/commit/d75499fea7524f939fb693a2c866ab1b246ae26d) Add a `useragent` field to `MitmResponse.LoginResponse` to align with new controller updates.

- [14-04-2024 - ef1ccce:](https://github.com/UnownHash/RotomProtos/commit/ef1ccce6e1fc40bdec36335857cd95ad2876a18f) Add Facebook/Google as login sources to `MitmRequest.LoginRequest.LoginSource` as controllers start accepting Facebook/Google accounts.

- [29-05-2024 - 2ee6d0f:](https://github.com/UnownHash/RotomProtos/commit/2ee6d0f2809cc42e1e714f7179f289d5b4512645) Add `N_KIDS` to `MitmRequest.LoginRequest.LoginSource` since controllers started adapting Niantic Kids as a new way to map without relying on PTC. It was later learned that the login source is actually `SUPER_AWESOME`, not `N_KIDS`.

- [23-09-2024 - 4677808:](https://github.com/UnownHash/RotomProtos/commit/46778084df2593d4281075c93d30f55594681c38) Add two new RPC response methods to be able to counter Google Play (Google Play Integrity/Google SafetyNet)-related methods.

- [28-08-2026 - XXXXXXX:](https://github.com/UnownHash/RotomProtos/blob/main/rotom.proto) **Will be updated on next PR, as the commit hash is unobtainable now.** Add new `NIANTIC_JWT` login method to align with the new Niantic Kids authentication flow and to support the (most likely to happen) upcoming authentication flow changes.

- [26-09-2026 - XXXXXXX:](https://github.com/UnownHash/RotomProtos/blob/main/rotom.proto) **Will be updated on next PR, as the commit hash is unobtainable now.** Add the missing `AUTH_STATUS_GOOGLE_PLAY_NOT_READY` and `AUTH_STATUS_LOGIN_ERROR_BAIL` authentication statuses, so that the Google Play-related and bail-out login failures already reportable through `RpcStatus` can also be reported on a login response.

## Full `rotom.proto` Explanation

Protos will be explained in the following format: `### MitmRequest => LoginRequest => LoginSource`

---

### Message - MitmRequest

#### Enum - Method:

- `0 - UNSET`: Unhandled/out of scope method.
- `1 - LOGIN`: Method to request a MITM login.
- `2 - RPC_REQUEST`: Method to ask the MITM to send a RPC request.

#### Message - LoginRequest:

##### Enum - LoginSource:

- `0 - UNSET`: Unhandled/out of scope login source.
- `1 - PTC [deprecated = true]`: DEPRECATED - Old PTC login method, pre-update.
- `2 - PTC_OAUTH`: Updated PTC OAuth flow login source.
- `3 - FB`: Facebook OAuth login method.
- `4 - GOOGLE`: Google OAuth login method.
- `5 - SUPER_AWESOME [deprecated = true]`: DEPRECATED - Old Niantic Kids login method, now deprecated and using the new `NIANTIC_JWT` login method.
- `6 - NIANTIC_JWT`: New auth flow, will (most likely) eventually replace all other login methods.

##### Fields:

- `string username = 1`: Account username.
- `LoginSource source = 2`: The `LoginSource` enum containing the selected login method.
- `bytes token_proto = 3`: The pre-encoded proto (encoded by the controller) containing the token in the game-required format.
- `string worker_id = 4`: The worker ID the controller assigned.
- `bool enable_compression = 5`: Whether to enable Rotom's compression or not.

#### Message - RpcRequest:

##### Message - SingleRpcRequest:

###### Fields:

- `int32 method = 1`: RPC method ID.
- `bytes payload = 2`: Pre-encoded (encoded by the controller) protobuf payload.
- `bool is_compressed = 3`: Whether it's compressed or not.

##### Fields:

- `repeated SingleRpcRequest request = 1`: The single RPC request proto mentioned above.
- `double lat = 2`: Latitude of the location the RPC should be sent from.
- `double lon = 3`: Longitude of the location the RPC should be sent from.

#### Fields:

- `uint32 id = 1`: Unique request ID used to associate the request with its response.
- `Method method = 2`: The `Method` enum containing the requested MITM method.

#### Oneof - payload:

- `LoginRequest login_request = 3`: The login request payload when requesting a MITM login.
- `RpcRequest rpc_request = 4`: The RPC request payload when requesting the MITM to send one or more RPC requests.

---

### Message - MitmResponse

#### Enum - Status:

- `0 - UNSET`: Unhandled/out of scope response status.
- `200 - SUCCESS`: Request successfully completed.
- `500 - ERROR_UNKNOWN`: Unknown MITM error.
- `501 - ERROR_RETRY_LATER`: Temporary error where the controller should retry later.
- `502 - ERROR_WORKER_STOPPED`: The assigned worker has stopped.
- `503 - ERROR_RECONNECT`: The controller should reconnect to the MITM - with a new account.
- `504 - ERROR_RESTART_SESSION`: The controller should restart the current worker session - with the same account.

#### Message - LoginResponse:

##### Fields:

- `string worker_id = 1`: Worker ID associated with the login/session.
- `AuthStatus status = 2`: The authentication status returned by the worker.
- `bool supports_compression = 3`: Whether the MITM supports Rotom compression.
- `string useragent = 4`: User agent used by the worker.

#### Message - RpcResponse:

##### Message - SingleRpcResponse:

###### Fields:

- `int32 method = 1`: RPC method ID.
- `bytes payload = 2`: Pre-encoded protobuf response payload.
- `bool is_compressed = 3`: Whether the response payload is compressed or not.

##### Fields:

- `RpcStatus rpc_status = 1`: The status of the RPC request.
- `repeated SingleRpcResponse response = 2`: The returned single RPC responses.

#### Fields:

- `uint32 id = 1`: Request ID matching the corresponding `MitmRequest`.
- `Status status = 2`: General MITM response status.

#### Oneof - payload:

- `LoginResponse login_response = 3`: Response payload for a login request.
- `RpcResponse rpc_response = 4`: Response payload for a RPC request.

#### Fields:

- `string mitm_error = 100`: Optional custom MITM error message containing more detailed error information.

---

### Message - WelcomeMessage

#### Enum - Platform:

- `0 - UNSET`: Unknown/unset worker platform.
- `1 - IOS`: Worker is running on iOS.
- `2 - ANDROID`: Worker is running on Android.

#### Fields:

- `string worker_id = 1`: Unique worker ID.
- `string origin = 2`: Origin/implementation of the worker.
- `int32 version_code = 3`: Numeric game version code running on the worker.
- `string version_name = 4`: Human-readable game version running on the worker.
- `string useragent = 5`: User agent used by the worker.
- `string device_id = 6`: Device ID of the worker device.
- `Platform platform = 7`: The platform the worker is running on.
- `bool reserved1 = 8`: Reserved field.
- `string reserved2 = 9`: Reserved field.

---

### Enum - AuthStatus

- `0 - AUTH_STATUS_UNSET`: Authentication status is unset or unknown.
- `1 - AUTH_STATUS_AUTH_TOKEN_REQUEST_FAILED`: Requesting an authentication token failed.
- `2 - AUTH_STATUS_AUTH_TOKEN_REQUESTED`: An authentication token has been requested.
- `3 - AUTH_STATUS_GOT_AUTH_TOKEN`: An authentication token was successfully received.
- `4 - AUTH_STATUS_DEVICE_INCOMPATIBLE`: The device is incompatible.
- `5 - AUTH_STATUS_USER_NOT_FOUND`: The requested user/account could not be found.
- `6 - AUTH_STATUS_ACCESS_DENIED`: Access was denied.
- `7 - AUTH_STATUS_ACCESS_SUSPENDED`: Access to the account has been suspended.
- `8 - AUTH_STATUS_ACCESS_RATE_LIMITED`: Access has been rate limited.
- `9 - AUTH_STATUS_SESSION_TERMINATED`: The current session was terminated.
- `10 - AUTH_STATUS_SESSION_FAILED`: The current session failed.
- `11 - AUTH_STATUS_GOOGLE_PLAY_NOT_READY`: Required Google Play functionality (Google Play Integrity/Google SafetyNet) is not ready, so the login could not be completed. The `AuthStatus` counterpart of `RPC_STATUS_GOOGLE_PLAY_NOT_READY`.
- `12 - AUTH_STATUS_LOGIN_ERROR_BAIL`: A login error occurred and the login flow should be abandoned instead of retried. The `AuthStatus` counterpart of `RPC_STATUS_LOGIN_ERROR_BAIL`.
- `20 - AUTH_STATUS_LOGIN_TIMEOUT`: The login attempt timed out.

---

### Enum - RpcStatus

- `0 - RPC_STATUS_UNDEFINED`: RPC status is undefined or unset.
- `1 - RPC_STATUS_SUCCESS`: RPC request completed successfully.
- `3 - RPC_STATUS_BAD_RESPONSE`: An invalid/bad RPC response was received.
- `4 - RPC_STATUS_ACTION_ERROR`: An error occurred while handling the requested action.
- `5 - RPC_STATUS_DISPATCH_ERROR`: The RPC request could not be dispatched.
- `6 - RPC_STATUS_SERVER_ERROR`: A server-side RPC error occurred.
- `7 - RPC_STATUS_ASSIGNMENT_ERROR`: An error occurred while assigning the RPC request.
- `8 - RPC_STATUS_PROTOCOL_ERROR`: A protocol-related error occurred.
- `9 - RPC_STATUS_AUTHENTICATION_ERROR`: An authentication-related RPC error occurred.
- `10 - RPC_STATUS_CANCELLED_REQUEST`: The RPC request was cancelled.
- `11 - RPC_STATUS_UNKNOWN_ERROR`: An unknown RPC error occurred.
- `12 - RPC_STATUS_NO_RETRIES_ERROR`: The RPC failed and should not be retried.
- `13 - RPC_STATUS_UNAUTHORIZED_ERROR`: The RPC request was unauthorized.
- `14 - RPC_STATUS_PARSING_ERROR`: The RPC request or response could not be parsed.
- `15 - RPC_STATUS_ACCESS_DENIED`: RPC access was denied.
- `16 - RPC_STATUS_ACCESS_SUSPENDED`: RPC access was suspended.
- `17 - RPC_STATUS_DEVICE_INCOMPATIBLE`: The device was considered incompatible.
- `18 - RPC_STATUS_ACCESS_RATE_LIMITED`: RPC access was rate limited.
- `19 - RPC_STATUS_GOOGLE_PLAY_NOT_READY`: Required Google Play functionality is not ready.
- `20 - RPC_STATUS_LOGIN_ERROR_BAIL`: A login error occurred and the current flow should be abandoned.
- `99 - RPC_STATUS_MITM_DISALLOWED_REQUEST`: The MITM disallowed the requested RPC.

---

### Message - RegisterControllerRequest

#### Fields:

- `string id = 1`: Unique controller ID.
- `int32 proto_major_version = 2`: Major Rotom protocol version supported by the controller.
- `int32 proto_minor_version = 3`: Minor Rotom protocol version supported by the controller.
- `int32 weight = 4`: Controller weight used when distributing workers between controllers.

---

### Message - RegisterControllerResponse

#### Enum - RegisterControllerResponseStatus:

- `0 - UNSET`: Registration status is unset or unknown.
- `1 - SUCCESS`: Controller registration succeeded.
- `2 - NO_WORKERS_AVAILABLE`: There are currently no workers available to assign.
- `3 - ERROR`: An error occurred while registering the controller.

#### Fields:

- `RegisterControllerResponseStatus status = 1`: Status of the controller registration attempt.
- `string status_reason = 2`: Additional human-readable information about the registration status.
- `string user_agent = 3`: User agent associated with the assigned worker.
- `int32 proto_major_version = 4`: Major Rotom protocol version supported by the MITM.
- `int32 proto_minor_version = 5`: Minor Rotom protocol version supported by the MITM.
- `string assigned_worker_id = 7`: Worker ID assigned to the controller.
- `int64 retry_after = 8`: Value indicating when the controller should retry after a temporary registration failure.
