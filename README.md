# Poke (poke-your-api)
Manage your curl requests with ease

## Usage
1. install `poke-your-api` gem by running `gem install poke-your-api`
1. run `poke init` (generates `~/.poke` directory)
1. Run `poke` and enjoy

### Environments
Use `poke env` to manage environments.

Use `poke -e env_name` to run the request against the specified environment.

### Configuration
Configuration can be changed by creating `~/.poke.json` file.

```json
{
  "root_path": "/Users/username/.poke",
  "aliases": { 
    "foo": "example_api/get",
  }
}
```

### Aliases
Use `poke -N alias_name` to set the alias for chosen request.

Use `poke -n alias_name` to run the request with the specified alias.

## Copyright

Copyright (c) 2023 MrBananaLord. See [MIT License](LICENSE.txt) for further details.