-- # AutoMerge
--
\pset linestyle unicode
\pset border 2
\pset pager off
--
-- This documentation is also tests for the code, the examples below
-- show the literal output of these statements from Postgres.
--
-- Some setup to make sure the extension is installed.

set client_min_messages = 'WARNING'; -- pragma:hide
create extension if not exists automerge;
set search_path to public,automerge;

-- ## Casting to/from jsonb
--
-- Automerge centers around a document object called
-- `automerge.autodoc`.  This type can be created by casting a jsonb
-- object to `autodoc`:

select pg_typeof('{"foo":1}'::autodoc);

-- An `autodoc` instance looks like a `bytea` type, which internally
-- encodes the state of the document.  This casting operation supports
-- all the Postgres jsonb types.  jsonb doesn't have a distinction
-- between integers and floats, but autodoc automatically detects them
-- and creates the right autodoc value.
--
-- You can cast back to `jsonb`:

select '{"foo":1}'::autodoc::jsonb;

-- Note that casting to jsonb is a potentially lossy operation, since
-- autodoc support more types of values than jsonb does, such as
-- timestamps and counters.  These types are ignored when casting to
-- jsonb, so be aware of that.

-- ## Merging documents
--
-- Documents can be merged together into one:

select merge('{"foo":1}'::autodoc, '{"bar":2}'::autodoc)::jsonb;

-- ## Getting scalar values
--
-- Scalar values can be retrived from the document by their key:

-- ### Integers

select get_int('{"foo":1}'::autodoc, 'foo');

select put_int('{"foo":1}'::autodoc, 'bar', 2)::jsonb;

select get_int('{"foo":1}'::autodoc, 'bar');

-- ### Strings

select get_str('{"foo":"bar"}'::autodoc, 'foo');

select put_str('{"foo":"bar"}'::autodoc, 'bing', 'bang')::jsonb;

select get_str('{"foo":"bar"}'::autodoc, 'bar');

-- ### Doubles

select get_double('{"pi":3.14159}'::autodoc, 'pi');

select put_double('{"pi":3.14159}'::autodoc, 'e', 2.71828)::jsonb;

select get_double('{"pi":3.14159}'::autodoc, 'e');

-- ### Bools

select get_bool('{"foo":true}'::autodoc, 'foo');

select put_bool('{"foo":true}'::autodoc, 'bar', false)::jsonb;

select get_bool('{"foo":true}'::autodoc, 'bar');

-- ### Counters
--
-- NOTE: Counters have no jsonb input representation, on output they
-- are represented as JSON integer.

select put_counter('{}'::autodoc, 'bar', 1)::jsonb;

select get_counter(put_counter('{}'::autodoc, 'bar', 1), 'bar');

select get_counter(inc_counter(put_counter('{}'::autodoc, 'bar', 1), 'bar'), 'bar');

select get_counter(inc_counter(put_counter('{}'::autodoc, 'bar', 1), 'bar', 2), 'bar');

select get_counter(inc_counter(put_counter('{}'::autodoc, 'bar', 1), 'bar', -2), 'bar');

select get_counter(put_counter('{}'::autodoc, 'bar', 1), 'foo');

-- ### Text
--
-- Automerge Text objects are like strings but have support for
-- changing ("splicing") text in and out efficiently.
--
-- NOTE: Text have no jsonb input representation, on output they are
-- represented as JSON string.

select put_text('{"foo":"bar"}'::autodoc, 'bing', 'bang')::jsonb;

select get_text(put_text('{"foo":"bar"}'::autodoc, 'bing', 'bang'), 'bing');

select splice_text(put_text('{"foo":"bar"}'::autodoc, 'bing', 'bang'), 'bing', 1, 3, 'ork')::jsonb;

-- ## Actor Ids
--
-- Automerge supports a notion of "Actor Ids" that identify the actors
-- making concurrent changes to documents.  This UUID data can be get
-- and set with `get_actor_id(autodoc)` and `set_actor_id(autodoc,
-- uuid)`:
--

select get_actor_id(
    set_actor_id('{"foo":1}'::autodoc,
    '97131c66344c48e8b93249aabff6b2f2')
    );

-- ### Timestamp
--
-- TODO
--
-- ## Getting Changes
--
-- All changes can be retrieved with the `get_changes(autodoc)`
-- function:
--
--- select * from get_changes('{"foo":{"bar":1}}'::autodoc);
--
