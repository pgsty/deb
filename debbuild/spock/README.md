# Spock package compatibility

`pgedge-18` bundles Spock, LOLOR and Snowflake in `/usr/pgedge-18`.
Starting with Spock 5.0.12, `pgedge-18-spock` is an architecture-independent
compatibility package that depends on the matching pgEdge kernel. It owns
only its package documentation; extension binaries, SQL and controls belong
to `pgedge-18`, avoiding duplicate-file installation failures.

The pgEdge kernel replaces and breaks older standalone Spock packages.
Build the `pgedge` recipe before testing installation of this compatibility
package. No debug package is expected because it contains no native binary.
