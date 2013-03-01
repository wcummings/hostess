hostess
=======

A simple table manager

Design based on Steve Vinoski's blog post, "Don't Lose Your ets Tables":
http://steve.vinoski.net/blog/2011/03/23/dont-lose-your-ets-tables/

Usage
-----

Hostess creates a server, which manages your table, and an additional process
for each table. These processes are registered with the same name as the table.

To create a new hostess table:

<pre>
hostess:new(my_table).
</pre>

All hostess tables are public, so you can access the table directly with ets.

If you'd like to access the table through its parent process, use the trans/1
operation:

<pre>
hostess:trans(my_table, fun (Tbl) -> ets:insert(Tbl, {test, 1}) end).
</pre>

To delete a table:

<pre>
hostess:delete(my_table).
</pre>
