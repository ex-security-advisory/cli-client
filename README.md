# Elixir Security Advisory Project CLI Client

[![Build Status](https://travis-ci.com/ex-security-advisory/cli-client.svg?branch=master)](https://travis-ci.com/ex-security-advisory/cli-client)
[![Coverage Status](https://coveralls.io/repos/github/ex-security-advisory/cli-client/badge.svg?branch=master)](https://coveralls.io/github/ex-security-advisory/cli-client?branch=master)

**This project is not yet ready for production. Check back later.**

Client for the Elixir Security Vulnerability Project API.

## Installation

The package can be installed as an archive or as a dependency of your project by adding
`elixir_security_advisory_client` to your list of dependencies in `mix.exs` or calling
`mix archive.install elixir_security_advisory_client`:

```elixir
def deps do
  [
    {:elixir_security_advisory_client, "~> 1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/elixir_security_advisory_client](https://hexdocs.pm/elixir_security_advisory_client).

## Usage

 * `mix security.audit` – Check if vulnerable dependencies are found in your `mix.lock`
