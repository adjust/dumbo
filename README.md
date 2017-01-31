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

## Configuration

For some of its features Dumbo requires a database connection. For example when
building migration files between extension versions, Dumbo needs to install
these two versions on PostgreSQL and compare the respective Postgres objects.
Database connection settings are expected to be present in `config/database.yml`.
The expected structure of this file is:

    development:
      client_encoding: utf8
      user: postgres
      password:
      host: localhost
      port: 5432
      dbname: dumbo_test

Note that the keys follow the standard PostgreSQL [connection string
parameters](https://www.postgresql.org/docs/9.5/static/libpq-connect.html#LIBPQ-CONNSTRING).

## Usage

Dumbo comes with an executable, which would be your main interface to the
functionality of the framework.

### Initialize new PostgreSQL extension

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
    ├── pg_currency--0.1.0.sql
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

### Building the extension

Using Dumbo you'd typically write SQL in files under the `sql` directory and
optionally C code in the `src` directory. To concatenate the SQL files into the
required `extname--0.0.1.sql` extension file, Dumbo offers the following command:

    $ dumbo build

`dumbo new` builds this file for you, but for any following version
you'd need to run `dumbo build` in order to concatinate files in `sql/*.sql`
together.

Note that if you haven't bumped the extension version in the `extname.control`
file, subsequent `dumbo build` runs will overwrite the same generated file. This
comes handy while doing development work.

#### Using ERB templates

Files under `sql/*.sql.erb` and `src/*.{c,h}.erb` support templating using the
ERB format. If you use that feature I've no idea what will happen....

### Start a new version

To initialize a new version on an existing extension:

    $ dumbo bump [major|minor|patch]

Note that keeping to the (major.minor.patch) versioning is required. If no
argument is given, the default level for the version bump is `patch`. So given
a current version `0.1.0`:

    $ dumbo bump

will update the `*.control` file of the extension to version `0.1.1`.

### Create migrations between versions

Developing a PostgreSQL extension involves producing and releasing multiple
versions. To migrate from one version to version PostgreSQL supports the
mechanism of migration (upgrade & downgrade) files. These are files named like
`extname--0.0.1--0.0.2.sql` upgrading from version `0.0.1` to `0.0.2` and
`extname--0.0.2--0.0.1.sql` downgrading the other way.

Maintaining the changes between versions in these files manually is tedious and
error-prone and Dumbo does it for you automatically.

    $ dumbo migrations

Note that Dumbo differentiates between extension versions by looking for files structured
`extname--major.minor.patch.sql`. Here `extname` is the name of the extension
and the `major.minor.patch` is the version - e.g. `0.1.1`.

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
