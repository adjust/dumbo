[![Build Status](https://travis-ci.org/adjust/dumbo.svg?branch=version-1.0.0)](https://travis-ci.org/adjust/dumbo)

# Dumbo - the PostgreSQL Extension-Development Framework

Dumbo has been created with the purpose to facilitate development of PostgreSQL
extensions. Together with our [pgbundle
project](https://github.com/adjust/pgbundle) tool, it brings a lean approach
to the development of a bundle of PostgreSQL extension dependencies.

Some of the features the Dumbo framework offers are:

  * facilitated PostgreSQL extension initialization
  * improved version management
  * automated generation of upgrade/downgrade migrations
  * ERB templating support for automating repeated code generation

## Installation

To install Dumbo you can use rubygems' `gem` command from your command line:

    $ gem install dumbo

This should get you sorted instantly but in special system setup you might to
use `sudo` for this command to run.

## Usage

Dumbo comes with an executable, which would be your main interface to the
functionality of the framework.

### Start a new PostgreSQL extension

For new PG extension projects, Dumbo can generate a directory skeleton and
create the typical files for you.

    $ dumbo new myextname [Initial.Version.String] ['This extension is about that']

where "myextname" is the name for the new PG extension. As a stating point take
a look at the sample functions generated in `sql/myextname.sql` as well as the
generated `Makefile`.

The optional second argument sets the initial version for the new extension; the
default value is `0.0.1` but you could for example wish to start at `0.1.0`.
Note that the extension versions must follow the Semantic versioning style. An
optional third argument is a description on what the extension would be about.

So, as a concrete example, the following command line command command:

    $ dumbo new pg_currency 0.1.0 'A currency data-type for PostgreSQL'

would generate a project skeleton like this:

    pg_currency
    ├── Makefile
    ├── README.md
    ├── config
    │   └── database.yml
    ├── pg_currency.control
    ├── sql
    │   └── pg_currency.sql
    ├── src
    │   ├── pg_currency.c
    │   └── pg_currency.h
    └── test
        ├── expected
        │   └── pg_currency_test.out
        └── sql
            └── pg_currency_test.sql

This is already enough for you to go into the newly created directory and
install your extension against Postgres using standard `make install`.

Once installed, login to Postgres using `psql` and issue this SQL:

    CREATE EXTENSION pg_currency;

This skeleton includes the SQL declaration and C implementation of a sample
funcion called `add_one(int)`. Note that there's also an automatically
generated sample regression testsuite, which you can run using the standard:

    $ make installcheck

from your command line.

### Start a new version

To initialize a new version on an existing extension:

    $ dumbo bump [major|minor|patch]

Note that keeping to the (major.minor.patch) versioning is required. If no
argument is given, the default level for the version bump is `patch`. So given
a current version `0.1.0`:

    $ dumbo bump

will update the `*.control` file of the extension to version `0.1.1`.

### Create migrations between versions

TODO: illustrate this!

    $ dumbo migrations

### Using ERB templates

TODO: illustrate this!

![](http://img1.wikia.nocookie.net/__cb20091210033559/disney/images/7/76/Dumbo-HQ.JPG)

## Contributing

Contributions in form of Pull Request, documentation improvement and/or [issue
reports](https://github.com/adjust/dumbo/issues) are very welcome. To contribute
code:

1. Fork it (http://github.com/adjust/dumbo/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
