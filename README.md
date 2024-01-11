# Poke (poke-your-api)
Manage your curl requests with ease

## Usage
1. install `poke-your-api` gem by running `gem install poke-your-api`
1. run `poke init` (generates `~/.poke` directory)
1. Run `poke` and enjoy

### Environments
Use `poke env` to manage environments.

Use `poke -e env_name` to run the request against the specified environment.

### Aliases
Aliases are displayed next to the request name in parentheses.

Use `poke -N alias_name` to set the alias for chosen request.

Use `poke -n alias_name` to run the request with the specified alias.

### Editing requests
Use `poke -o -n alias_name` or `poke -o` to open the request in your default editor (you can overwrite it by setting `EDITOR` environment variable).

### Adding requests
Create a new `.curl` file in `~/.poke/<any_dir_with_config>/<any_file_or_dir_with_file>`.

The example directory tree could look like:
```
~/.poke
├── aliases.json  # autogenerated file
├── lru.json      # autogenerated file
├── response.json # autogenerated file
├── example_api
│   ├── config.json # example_api env variables
    ├── example_request.curl
└── your_api
    ├── config.json # your_api env variables
    ├── some_file.curl
    └── some_subdirectory
        └── some_file.curl
```

## Copyright

Copyright (c) 2023 MrBananaLord. See [MIT License](LICENSE.txt) for further details.