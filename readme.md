# Realtime Forms Test

A testing ground/example for the WIP [realtime-forms](https://github.com/dzuk-mutant/realtime-forms) package.


- Requires Elm 0.19.1 and uglifyjs to build the client.
    - Run `make elm` to build and run.
    - Run `make debug` to build the debug version.
- Requires json-server to run the test server.
    - Run `json-server --watch server/db.json` to run the server.


The code that makes up the realtime-forms package is in Form.elm and it's various submodules (Field, Validatable, etc.).


---

## Licenses

The realtime-forms package is released as BSD-3-Clause to conform to other Elm packages, but because this test contains various edited code elements from [Parastat](https://parast.at) (an open source project, currently under closed development until a certain point in the future) and because that will be licensed CNPL v4, this repo is licensed [CNPL v4](license.txt).

The styles have been built separately as part of Parastat's own UI framework, this has been done for the sake of convenience but because this is about Elm logic, the original styles are not included and do not need to be built.

- Manrope is licensed OFL SIL 1.1.
